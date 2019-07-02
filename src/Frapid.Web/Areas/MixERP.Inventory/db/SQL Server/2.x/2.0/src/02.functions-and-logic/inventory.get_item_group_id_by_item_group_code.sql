IF OBJECT_ID('inventory.get_item_group_id_by_item_group_code') IS NOT NULL
DROP FUNCTION inventory.get_item_group_id_by_item_group_code;

GO

CREATE FUNCTION inventory.get_item_group_id_by_item_group_code(@item_group_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT item_group_id
	    FROM inventory.item_groups
	    WHERE inventory.item_groups.item_group_code=@item_group_code
	    AND inventory.item_groups.deleted = 0
    );
END;




GO
