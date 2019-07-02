IF OBJECT_ID('inventory.get_store_id_by_store_name') IS NOT NULL
DROP FUNCTION inventory.get_store_id_by_store_name;

GO

CREATE FUNCTION inventory.get_store_id_by_store_name(@store_name national character varying(500))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT store_id
	    FROM inventory.stores
	    WHERE inventory.stores.store_name = @store_name
	    AND inventory.stores.deleted = 0
    );
END



GO
