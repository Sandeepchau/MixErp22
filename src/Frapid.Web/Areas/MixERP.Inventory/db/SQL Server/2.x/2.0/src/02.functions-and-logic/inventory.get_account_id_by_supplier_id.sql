IF OBJECT_ID('inventory.get_account_id_by_supplier_id') IS NOT NULL
DROP FUNCTION inventory.get_account_id_by_supplier_id;

GO

CREATE FUNCTION inventory.get_account_id_by_supplier_id(@supplier_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT
	        inventory.suppliers.account_id
	    FROM inventory.suppliers
	    WHERE inventory.suppliers.supplier_id = @supplier_id
	    AND inventory.suppliers.deleted = 0
	);
END;





GO
