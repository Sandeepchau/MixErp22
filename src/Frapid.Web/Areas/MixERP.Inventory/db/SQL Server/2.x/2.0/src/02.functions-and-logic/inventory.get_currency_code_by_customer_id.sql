IF OBJECT_ID('inventory.get_currency_code_by_customer_id') IS NOT NULL
DROP FUNCTION inventory.get_currency_code_by_customer_id;

GO

CREATE FUNCTION inventory.get_currency_code_by_customer_id(@customer_id integer)
RETURNS national character varying(12)
AS

BEGIN
    RETURN
    (
	    SELECT inventory.customers.currency_code
	    FROM inventory.customers
	    WHERE inventory.customers.customer_id = @customer_id
	    AND inventory.customers.deleted = 0
    );
END



GO
