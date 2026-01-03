-- TRY-CATCH
--BEGIN TRY
--END TRY
--BEGIN CATCH
--END CATCH

-- Creating Procedure Using Try-Catch
CREATE PROC sp_division (
	@a SMALLINT,
	@b SMALLINT
) AS
	BEGIN
		BEGIN TRY
			DECLARE  @c SMALLINT
			SET @c = @a / @b
		END TRY
		BEGIN CATCH
			SELECT 
				ERROR_MESSAGE() ErrorMessage
		END CATCH
	END;

-- Now Executing Procedure
EXEC sp_division 10, 0;

-- TRIGGERS
--CREATE TRIGGER [schema_name.]trigger_name
--ON table_name
--AFTER  {[INSERT],[UPDATE],[DELETE]}
--[NOT FOR REPLICATION]
--AS
--{sql_statements}

CREATE TABLE production.product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);


-- Creating Trigger
CREATE TRIGGER production.trg_product_audit
ON production.products
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO production.product_audits (
        product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        list_price,
        updated_at,
        operation
    )

    -- INSERT
    SELECT
        i.product_id,
        i.product_name,
        i.brand_id,
        i.category_id,
        i.model_year,
        i.list_price,
        GETDATE(),
        'INS'
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM deleted d WHERE d.product_id = i.product_id
    )

    UNION ALL

    -- DELETE
    SELECT
        d.product_id,
        d.product_name,
        d.brand_id,
        d.category_id,
        d.model_year,
        d.list_price,
        GETDATE(),
        'DEL'
    FROM deleted d
    WHERE NOT EXISTS (
        SELECT 1 FROM inserted i WHERE i.product_id = d.product_id
    )

    UNION ALL

    -- UPDATE
    SELECT
        i.product_id,
        i.product_name,
        i.brand_id,
        i.category_id,
        i.model_year,
        i.list_price,
        GETDATE(),
        'UPD'
    FROM inserted i
    INNER JOIN deleted d
        ON d.product_id = i.product_id;
END;


SELECT * FROM production.product_audits;

-- INSERTION in Table
INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'Test product',
    1,
    1,
    2018,
    599
);

-- DELETION in Table
DELETE FROM 
    production.products
WHERE 
    product_id = 1001;

UPDATE production.products
SET product_name = 'Test successfull'
WHERE product_name = 'TEST Successfull';

--CREATE TABLE production.product_audits_update (
--    change_id INT IDENTITY PRIMARY KEY,
--    product_id INT NOT NULL,
--    old_list_price DEC(10,2) NOT NULL,
--    new_list_price DEC(10,2) NOT NULL,
--    updated_at DATETIME NOT NULL,
--    operation CHAR(3) NOT NULL,
--    CHECK(operation = 'UPD')
--);

--drop trigger production.trg_product_audit_update;

--create trigger production.trg_product_audit_update
--ON production.products
--after UPDATE
--AS
--BEGIN
--insert into production.product_audits_update
--(
--            product_id,
--            old_list_price,new_list_price,
--            updated_at,
--            operation
--        )
--    SELECT
--        i.product_id,
--        d.list_price,i.list_price,
--        GETDATE(),
--        'UPD'
--    from inserted as i
--    INNER JOIN deleted d on d.product_id = i.product_id
--END;

--update production.products
--set  list_price = 55555
--where product_id = 3

--select * from production.products;

--select * from production.product_audits_update;

-- INSTEAD TRIGGER
--CREATE TRIGGER [schema_name.] trigger_name
--ON {table_name | view_name }
--INSTEAD OF {[INSERT] [,] [UPDATE] [,] [DELETE] }
--AS
--{sql_statements}

CREATE TABLE production.brand_approvals(
    brand_id INT IDENTITY PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

CREATE VIEW production.vw_brands 
AS
SELECT
    brand_name,
    'Approved' approval_status
FROM
    production.brands
UNION
SELECT
    brand_name,
    'Pending Approval' approval_status
FROM
    production.brand_approvals;

CREATE TRIGGER production.trg_vw_brands 
ON production.vw_brands
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO production.brand_approvals ( 
        brand_name
    )
    SELECT
        i.brand_name
    FROM
        inserted i
    WHERE
        i.brand_name NOT IN (
            SELECT 
                brand_name
            FROM
                production.brands
        );
END

INSERT INTO production.vw_brands(brand_name)
VALUES('Eddy Merckx');

SELECT * FROM production.vw_brands;
SELECT * FROM production.brand_approvals;