IF OBJECT_ID('inventory.get_store_name_by_store_id') IS NOT NULL
DROP FUNCTION inventory.get_store_name_by_store_id;

GO

CREATE FUNCTION inventory.get_store_name_by_store_id(@store_id integer)
RETURNS national character varying(500)
AS

BEGIN
    RETURN
    (
	    SELECT store_name
	    FROM inventory.stores
	    WHERE inventory.stores.store_id = @store_id
	    AND inventory.stores.deleted = 0
    );
END



GO
