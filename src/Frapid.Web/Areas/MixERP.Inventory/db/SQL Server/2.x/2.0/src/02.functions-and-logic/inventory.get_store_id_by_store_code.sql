IF OBJECT_ID('inventory.get_store_id_by_store_code') IS NOT NULL
DROP FUNCTION inventory.get_store_id_by_store_code;

GO

CREATE FUNCTION inventory.get_store_id_by_store_code(@store_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
        SELECT inventory.stores.store_id
        FROM inventory.stores
        WHERE inventory.stores.store_code=@store_code 
        AND inventory.stores.deleted = 0
    );
END;





GO
