IF OBJECT_ID('inventory.get_unit_id_by_unit_name') IS NOT NULL
DROP FUNCTION inventory.get_unit_id_by_unit_name;

GO

CREATE FUNCTION inventory.get_unit_id_by_unit_name(@unit_name national character varying(500))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT unit_id
	    FROM inventory.units
	    WHERE inventory.units.unit_name = @unit_name
	    AND inventory.units.deleted = 0
    );
END



GO
