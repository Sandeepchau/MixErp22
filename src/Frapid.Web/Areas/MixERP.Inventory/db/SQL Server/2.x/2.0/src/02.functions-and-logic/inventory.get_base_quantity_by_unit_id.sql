IF OBJECT_ID('inventory.get_base_quantity_by_unit_id') IS NOT NULL
DROP FUNCTION inventory.get_base_quantity_by_unit_id;

GO

CREATE FUNCTION inventory.get_base_quantity_by_unit_id(@unit_id integer, @multiplier numeric(30, 6))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @root_unit_id integer;
    DECLARE @factor numeric(30, 6);

    SET @root_unit_id = inventory.get_root_unit_id(@unit_id);
    SET @factor = inventory.convert_unit(@unit_id, @root_unit_id);

    RETURN @factor * @multiplier;
END;

GO
