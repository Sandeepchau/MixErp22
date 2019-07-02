IF OBJECT_ID('inventory.get_account_id_by_supplier_type_id') IS NOT NULL
DROP FUNCTION inventory.get_account_id_by_supplier_type_id;

GO

CREATE FUNCTION inventory.get_account_id_by_supplier_type_id(@supplier_type_id integer)
RETURNS integer
AS
BEGIN
    RETURN 
	(
		SELECT account_id
		FROM inventory.supplier_types
		WHERE supplier_type_id=@supplier_type_id
	);
END;

GO

--SELECT inventory.get_account_id_by_supplier_type_id(1);