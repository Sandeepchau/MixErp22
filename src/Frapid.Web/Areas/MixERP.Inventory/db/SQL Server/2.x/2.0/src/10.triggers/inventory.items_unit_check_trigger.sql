IF OBJECT_ID('inventory.items_unit_check_trigger') IS NOT NULL
DROP TRIGGER inventory.items_unit_check_trigger;

GO

CREATE TRIGGER inventory.items_unit_check_trigger
ON inventory.items
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INSERTED WHERE inventory.get_root_unit_id(INSERTED.unit_id) != inventory.get_root_unit_id(INSERTED.reorder_unit_id))
	BEGIN
        RAISERROR('The reorder unit is incompatible with the base unit.', 16, 1);
    END;
END

GO

