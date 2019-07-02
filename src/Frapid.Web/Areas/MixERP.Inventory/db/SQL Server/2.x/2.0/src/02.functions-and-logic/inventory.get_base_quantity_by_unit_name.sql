

-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.x/2.0/src/02.functions-and-logic/inventory.get_base_quantity_by_unit_name.sql --<--<--
IF OBJECT_ID('inventory.get_base_quantity_by_unit_name') IS NOT NULL
DROP FUNCTION inventory.get_base_quantity_by_unit_name;

GO

CREATE FUNCTION inventory.get_base_quantity_by_unit_name(@unit_name national character varying(500), @multiplier numeric(30, 6))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @unit_id integer;
    DECLARE @root_unit_id integer;
    DECLARE @factor numeric(30, 6);

    SET @unit_id = inventory.get_unit_id_by_unit_name(@unit_name);
    SET @root_unit_id = inventory.get_root_unit_id(@unit_id);
    SET @factor = inventory.convert_unit(@unit_id, @root_unit_id);

    RETURN @factor * @multiplier;
END;

GO
