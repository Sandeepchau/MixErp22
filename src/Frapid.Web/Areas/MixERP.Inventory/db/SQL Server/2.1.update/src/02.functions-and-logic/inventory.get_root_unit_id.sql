IF OBJECT_ID('inventory.get_root_unit_id') IS NOT NULL
DROP FUNCTION inventory.get_root_unit_id;

GO

CREATE FUNCTION inventory.get_root_unit_id(@any_unit_id integer)
RETURNS integer
AS
BEGIN
    DECLARE @root_unit_id integer;

    SELECT @root_unit_id = base_unit_id
    FROM inventory.compound_units
    WHERE inventory.compound_units.compare_unit_id=@any_unit_id
    AND inventory.compound_units.deleted = 0;

    IF(@root_unit_id IS NULL OR @root_unit_id = @any_unit_id)
    BEGIN
        RETURN @any_unit_id;
    END

    RETURN inventory.get_root_unit_id(@root_unit_id);
END;

GO
