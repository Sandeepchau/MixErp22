DROP FUNCTION IF EXISTS inventory.get_unit_name_by_unit_id(_unit_id integer);

CREATE FUNCTION inventory.get_unit_name_by_unit_id(_unit_id integer)
RETURNS national character varying(1000)
AS
$$
BEGIN
    RETURN unit_name
    FROM inventory.units
    WHERE inventory.units.unit_id = _unit_id
	AND NOT inventory.units.deleted;
END
$$
LANGUAGE plpgsql;