-- BRONZE LAYER NETFLIX DATA
SELECT * FROM bronze_layer_netflix_data;

-- CONVERTING TO SILVER LAYER NETFLIX DATA

--REMOVE DUPLICATES 
SELECT show_id,COUNT(*) 
FROM bronze_layer_netflix_data
GROUP BY show_id 
HAVING COUNT(*)>1;

SELECT * FROM bronze_layer_netflix_data
WHERE CONCAT(UPPER(title),type)  in (
SELECT CONCAT(UPPER(title),type) 
FROM bronze_layer_netflix_data
GROUP BY UPPER(title) ,type
HAVING COUNT(*)>1
)
ORDER BY title;

WITH CTE as (
SELECT * 
,ROW_NUMBER() OVER(PARTITION BY title , type ORDER BY show_id) rn
FROM bronze_layer_netflix_data
)
SELECT
	show_id,
	type,
	title,
	CAST(date_added date) date_added,
	release_year,
	rating,
	CASE WHEN duration IS NULL THEN rating ELSE duration END duration,
	description
INTO netflix
FROM CTE 

SELECT * FROM netflix;


SELECT show_id , TRIM(value) genre
INTO netflix_genre
FROM bronze_layer_netflix_data
CROSS APPLY STRING_SPLIT(listed_in,',');



SELECT * FROM bronze_layer_netflix_data;

-- SILVER LAYER NETFLIX DATA
SELECT * FROM bronze_layer_netflix_data;

-- CONVERTING TO SILVER LAYER NETFLIX DATA

-- for each director count the no of movies and tv shows created by them in separate columns 
-- for directors who have created tv shows and movies both */
SELECT 
    sld.director,
    COUNT(DISTINCT CASE WHEN sld.type = 'Movie' THEN sld.show_id END) no_of_movies,
    COUNT(DISTINCT CASE WHEN sld.type = 'TV Show' THEN sld.show_id END) no_of_tvshows
FROM silver_layer_netflix_data sld
GROUP BY sld.director
HAVING COUNT(DISTINCT sld.type) > 1;


--2 which country has highest number of comedy movies 
SELECT TOP 1 
    snc.country, 
    COUNT(DISTINCT sng.show_id) no_of_movies
FROM silver_layer_netflix_data sld
INNER JOIN silver_layer_netflix_genre sng ON sld.show_id = sng.show_id
INNER JOIN silver_layer_netflix_country snc ON sld.show_id = snc.show_id
WHERE sng.genre = 'Comedies' 
  AND sld.type = 'Movie'
GROUP BY snc.country
ORDER BY no_of_movies DESC;



--3 for each year (as per date added to netflix), which director has maximum number of movies released
WITH cte AS (
    SELECT 
        sld.director, 
        YEAR(sld.date_added) date_year, 
        COUNT(sld.show_id) no_of_movies
    FROM silver_layer_netflix_data sld
    WHERE sld.type = 'Movie'
    GROUP BY sld.director, YEAR(sld.date_added)
),
cte2 AS (
    SELECT 
        cte.*, 
        ROW_NUMBER() OVER(PARTITION BY date_year ORDER BY no_of_movies DESC, sld.director) rn
    FROM cte
)
SELECT * FROM cte2 
WHERE rn = 1;




--4 what is average duration of movies in each genre
SELECT 
    sng.genre, 
    AVG(CAST(REPLACE(sld.duration, ' min', '') INT)) avg_duration
FROM silver_layer_netflix_data sld
INNER JOIN silver_layer_netflix_genre sng ON sld.show_id = sng.show_id
WHERE sld.type = 'Movie'
GROUP BY sng.genre;


--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 
SELECT 
    sld.director,
    COUNT(DISTINCT CASE WHEN sng.genre = 'Comedies' THEN sld.show_id END) no_of_comedy,
    COUNT(DISTINCT CASE WHEN sng.genre = 'Horror Movies' THEN sld.show_id END) no_of_horror
FROM silver_layer_netflix_data sld
INNER JOIN silver_layer_netflix_genre sng ON sld.show_id = sng.show_id
WHERE sld.type = 'Movie' 
  AND sng.genre IN ('Comedies', 'Horror Movies')
GROUP BY sld.director
HAVING COUNT(DISTINCT sng.genre) = 2;

-- GOLD LAYER NETFLIX DATA
SELECT * FROM bronze_layer_netflix_data;