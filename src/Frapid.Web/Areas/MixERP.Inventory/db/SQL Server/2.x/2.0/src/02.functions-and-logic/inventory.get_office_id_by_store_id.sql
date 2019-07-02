IF OBJECT_ID('inventory.get_office_id_by_store_id') IS NOT NULL
DROP FUNCTION inventory.get_office_id_by_store_id;

GO

CREATE FUNCTION inventory.get_office_id_by_store_id(@store_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.stores.office_id
	    FROM inventory.stores
	    WHERE inventory.stores.store_id=@store_id
	    AND inventory.stores.deleted = 0
    );
END;




GO
