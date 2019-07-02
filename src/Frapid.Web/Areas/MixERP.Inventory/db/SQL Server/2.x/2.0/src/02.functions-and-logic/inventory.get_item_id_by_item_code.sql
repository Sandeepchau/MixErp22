IF OBJECT_ID('inventory.get_item_id_by_item_code') IS NOT NULL
DROP FUNCTION inventory.get_item_id_by_item_code;

GO

CREATE FUNCTION inventory.get_item_id_by_item_code(@item_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT item_id
	    FROM inventory.items
	    WHERE inventory.items.item_code = @item_code
	    AND inventory.items.deleted = 0
    );
END



GO
