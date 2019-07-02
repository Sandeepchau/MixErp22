IF OBJECT_ID('inventory.get_account_id_by_customer_type_id') IS NOT NULL
DROP FUNCTION inventory.get_account_id_by_customer_type_id;

GO

CREATE FUNCTION inventory.get_account_id_by_customer_type_id(@customer_type_id integer)
RETURNS integer
AS
BEGIN
    RETURN 
	(
		SELECT account_id
		FROM inventory.customer_types
		WHERE customer_type_id=@customer_type_id
	);
END;

GO

--SELECT inventory.get_account_id_by_customer_type_id(1);