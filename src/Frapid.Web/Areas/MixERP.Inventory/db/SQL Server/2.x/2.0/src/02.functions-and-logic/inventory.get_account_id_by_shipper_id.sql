IF OBJECT_ID('inventory.get_account_id_by_shipper_id') IS NOT NULL
DROP FUNCTION inventory.get_account_id_by_shipper_id;

GO

CREATE FUNCTION inventory.get_account_id_by_shipper_id(@shipper_id integer)
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT inventory.shippers.account_id
	    FROM inventory.shippers
	    WHERE inventory.shippers.shipper_id=@shipper_id
	    AND inventory.shippers.deleted = 0
    );
END;

GO
