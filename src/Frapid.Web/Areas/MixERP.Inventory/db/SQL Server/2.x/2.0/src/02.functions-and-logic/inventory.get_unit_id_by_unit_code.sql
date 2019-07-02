IF OBJECT_ID('inventory.get_unit_id_by_unit_code') IS NOT NULL
DROP FUNCTION inventory.get_unit_id_by_unit_code;

GO

CREATE FUNCTION inventory.get_unit_id_by_unit_code(@unit_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.units.unit_id
	    FROM inventory.units
	    WHERE inventory.units.unit_code=@unit_code
	    AND inventory.units.deleted = 0
    );
END;




GO
