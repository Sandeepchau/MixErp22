IF OBJECT_ID('inventory.get_unit_name_by_unit_id') IS NOT NULL
DROP FUNCTION inventory.get_unit_name_by_unit_id;

GO

CREATE FUNCTION inventory.get_unit_name_by_unit_id(@unit_id integer)
RETURNS national character varying(1000)
AS

BEGIN
    RETURN
    (
	    SELECT unit_name
	    FROM inventory.units
	    WHERE inventory.units.unit_id = @unit_id
	    AND inventory.units.deleted = 0
    );
END



GO
