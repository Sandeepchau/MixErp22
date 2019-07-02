IF OBJECT_ID('inventory.get_account_id_by_customer_id') IS NOT NULL
DROP FUNCTION inventory.get_account_id_by_customer_id;

GO

CREATE FUNCTION inventory.get_account_id_by_customer_id(@customer_id integer)
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT inventory.customers.account_id
	    FROM inventory.customers
	    WHERE inventory.customers.customer_id=@customer_id
	    AND inventory.customers.deleted = 0
    );
END;


GO
