IF OBJECT_ID('inventory.get_item_type_id_by_item_type_code') IS NOT NULL
DROP FUNCTION inventory.get_item_type_id_by_item_type_code;

GO

CREATE FUNCTION inventory.get_item_type_id_by_item_type_code(@item_type_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT item_type_id
	    FROM inventory.item_types
	    WHERE inventory.item_types.item_type_code=@item_type_code 
	    AND inventory.item_types.deleted = 0
    );
END;




GO
