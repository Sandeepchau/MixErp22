DROP FUNCTION IF EXISTS inventory.get_unit_id_by_unit_name(_unit_name text);

CREATE FUNCTION inventory.get_unit_id_by_unit_name(_unit_name text)
RETURNS integer
AS
$$
BEGIN
    RETURN unit_id
    FROM inventory.units
    WHERE inventory.units.unit_name = _unit_name
	AND NOT inventory.units.deleted;
END
$$
LANGUAGE plpgsql;