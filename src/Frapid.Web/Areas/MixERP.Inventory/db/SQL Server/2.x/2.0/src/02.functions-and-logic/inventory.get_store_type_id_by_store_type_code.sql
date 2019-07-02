IF OBJECT_ID('inventory.get_store_type_id_by_store_type_code') IS NOT NULL
DROP FUNCTION inventory.get_store_type_id_by_store_type_code;

GO

CREATE FUNCTION inventory.get_store_type_id_by_store_type_code(@store_type_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT store_type_id
	    FROM inventory.store_types
	    WHERE inventory.store_types.store_type_code=@store_type_code
	    AND inventory.store_types.deleted = 0
    );
END;




GO
