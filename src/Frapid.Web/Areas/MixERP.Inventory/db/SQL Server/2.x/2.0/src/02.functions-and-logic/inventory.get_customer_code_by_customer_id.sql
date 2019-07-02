IF OBJECT_ID('inventory.get_customer_code_by_customer_id') IS NOT NULL
DROP FUNCTION inventory.get_customer_code_by_customer_id;

GO

CREATE FUNCTION inventory.get_customer_code_by_customer_id(@customer_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT inventory.customers.customer_code
	    FROM inventory.customers
	    WHERE inventory.customers.customer_id = @customer_id
    );
END;

GO
