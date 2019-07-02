DROP FUNCTION IF EXISTS inventory.get_base_quantity_by_unit_name(text, numeric(30, 6));

CREATE FUNCTION inventory.get_base_quantity_by_unit_name(text, numeric(30, 6))
RETURNS numeric(30, 6)
STABLE
AS
$$
	DECLARE _unit_id integer;
	DECLARE _root_unit_id integer;
	DECLARE _factor numeric(30, 6);
BEGIN
    _unit_id := inventory.get_unit_id_by_unit_name($1);
    _root_unit_id = inventory.get_root_unit_id(_unit_id);
    _factor = inventory.convert_unit(_unit_id, _root_unit_id);

    RETURN _factor * $2;
END
$$
LANGUAGE plpgsql;

