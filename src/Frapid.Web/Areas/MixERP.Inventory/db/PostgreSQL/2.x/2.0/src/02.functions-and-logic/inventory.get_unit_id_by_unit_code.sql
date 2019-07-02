DROP FUNCTION IF EXISTS inventory.get_unit_id_by_unit_code(text);

CREATE FUNCTION inventory.get_unit_id_by_unit_code(text)
RETURNS integer
AS
$$
BEGIN
        RETURN inventory.units.unit_id
        FROM inventory.units
        WHERE inventory.units.unit_code=$1
		AND NOT inventory.units.deleted;
END
$$
LANGUAGE plpgsql;
