IF OBJECT_ID('inventory.get_base_unit_id_by_unit_name') IS NOT NULL
DROP FUNCTION inventory.get_base_unit_id_by_unit_name;

GO

CREATE FUNCTION inventory.get_base_unit_id_by_unit_name(@unit_name national character varying(500))
RETURNS integer
AS
BEGIN
    DECLARE @unit_id integer;

    SET @unit_id = inventory.get_unit_id_by_unit_name(@unit_name);

    RETURN inventory.get_root_unit_id(@unit_id);
END;


GO
