IF OBJECT_ID('sales.get_receivable_account_for_check_receipts') IS NOT NULL
DROP FUNCTION sales.get_receivable_account_for_check_receipts;

GO

CREATE FUNCTION sales.get_receivable_account_for_check_receipts(@store_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.stores.default_account_id_for_checks
	    FROM inventory.stores
	    WHERE inventory.stores.store_id = @store_id
	    AND inventory.stores.deleted = 0
	);
END;





GO
