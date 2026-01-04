--DDL TRIGGERS
--CREATE TRIGGER trigger_name
--ON { DATABASE |  ALL SERVER}
--[WITH ddl_trigger_option]
--FOR {event_type | event_group }
--AS {sql_statement}

CREATE TABLE index_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);

-- CREATING TRIGGER
CREATE TRIGGER trg_index_changes
ON DATABASE
FOR	
    CREATE_INDEX,
    ALTER_INDEX, 
    DROP_INDEX
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;

-- Create a Non Cluster Index
CREATE NONCLUSTERED INDEX idx_fname
ON [sales].[customers](first_name);

SELECT * FROM index_logs

-- NOW FOR VIEWS
CREATE TABLE view_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);

CREATE TRIGGER trg_view_changes
ON DATABASE
FOR	
    CREATE_VIEW,
    ALTER_VIEW, 
    DROP_VIEW
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO view_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;

CREATE VIEW view_fname
AS
	SELECT first_name
	FROM sales.customers ;

SELECT * FROM view_logs;


-- DISANLE TRIGGER
--DISABLE TRIGGER [schema_name.][trigger_name] 
--ON [object_name | DATABASE | ALL SERVER]

DISABLE TRIGGER trg_view_changes
ON DATABASE;

-- DISABLE ALL TRIGGERS
DISABLE TRIGGER ALL ON DATABASE;

CREATE VIEW vw_orders AS
SELECT * FROM [sales].[customers];

-- ENABLE TRIGGERS
ENABLE TRIGGER trg_view_changes
ON DATABASE;

CREATE VIEW vw_staffs 
AS
	SELECT *
	FROM sales.staffs;

-- TRIGGERS DEFINITIONS
SELECT definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('production.trg_product_audit');

-- ALL Y+TRIGGERS NAME
SELECT * FROM sys.triggers;

-- DROPPING TRIGGER ON SCHEMA
DROP TRIGGER production.trg_product_audit;

-- DROPPING TRIGGER ON DATABASE
DROP TRIGGER trg_view_changes
ON DATABASE;

-- SCALAR FUNCTION
--CREATE FUNCTION [schema_name.]function_name (parameter_list)
--RETURNS data_type AS
--BEGIN
--    statements
--    RETURN value
--END

CREATE FUNCTION sales.fn_NetSales (
    @quantity SMALLINT,
    @list_price DEC(10,2),
    @discount DEC(4,2)
)
RETURNS DEC(10,2)
AS 
BEGIN
    RETURN @quantity * @list_price * (1 - @discount);
END;

SELECT sales.fn_NetSales(2, 10.5, 0.25) AS NetPrice;


-- CUSTOM FUNCTION
CREATE FUNCTION sales.fn_discountValue (
	@quantity SMALLINT,
	@list_price DEC(10,2),
	@discount DEC(4,2)
)
RETURNS DEC(10,2)
AS
BEGIN
	RETURN @quantity * @list_price * (@discount)
END;

SELECT sales.fn_discountValue(2, 10.5, 0.25) AS DiscPrice;

-- TABLE-VALUED FUNCTION
CREATE FUNCTION sales.fn_ProductsByModelYear (
    @model_year SMALLINT
)
RETURNS TABLE
AS
RETURN
    SELECT *
    FROM
        production.products
    WHERE
        model_year = @model_year;

SELECT * FROM sales.fn_ProductsByModelYear(2016);

-- TEMP(TABLE) VARIABLES
--DECLARE @table_variable_name TABLE (
--    column_list
--);

DECLARE @product_table TABLE (
    product_name VARCHAR(MAX) NOT NULL,
    brand_id INT NOT NULL,
    list_price DEC(11,2) NOT NULL
);

-- INSERTING IN TABLE VARIABLE
INSERT INTO @product_table
SELECT
    product_name,
    brand_id,
    list_price
FROM
    production.products
WHERE
    category_id = 1;

-- QURYING YABLE VARIABLE
SELECT
    *
FROM
    @product_table;
