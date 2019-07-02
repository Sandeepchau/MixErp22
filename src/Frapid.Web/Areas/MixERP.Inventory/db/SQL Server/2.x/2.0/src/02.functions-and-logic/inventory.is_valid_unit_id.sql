IF OBJECT_ID('inventory.is_valid_unit_id') IS NOT NULL
DROP FUNCTION inventory.is_valid_unit_id;

GO

CREATE FUNCTION inventory.is_valid_unit_id(@unit_id integer, @item_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM inventory.items
        WHERE inventory.items.item_id = @item_id
        AND inventory.get_root_unit_id(@unit_id) = inventory.get_root_unit_id(unit_id)
        AND inventory.items.deleted = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;





GO
