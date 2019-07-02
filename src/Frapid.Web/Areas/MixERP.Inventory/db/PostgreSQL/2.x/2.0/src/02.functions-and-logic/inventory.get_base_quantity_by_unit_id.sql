DROP FUNCTION IF EXISTS inventory.get_base_quantity_by_unit_id(integer, numeric(30, 6));

CREATE FUNCTION inventory.get_base_quantity_by_unit_id(integer, numeric(30, 6))
RETURNS numeric(30, 6)
STABLE
AS
$$
	DECLARE _root_unit_id integer;
	DECLARE _factor numeric(30, 6);
BEGIN
    _root_unit_id = inventory.get_root_unit_id($1);
    _factor = inventory.convert_unit($1, _root_unit_id);

    RETURN _factor * $2;
END
$$
LANGUAGE plpgsql;
