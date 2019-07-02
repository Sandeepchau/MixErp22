DROP FUNCTION IF EXISTS inventory.get_associated_units_by_item_id(_item_id integer);

CREATE FUNCTION inventory.get_associated_units_by_item_id(_item_id integer)
RETURNS TABLE
(
    unit_id integer, 
    unit_code text, 
    unit_name text
)
AS
$$
    DECLARE _unit_id integer;
BEGIN
    SELECT inventory.items.unit_id INTO _unit_id
    FROM inventory.items
    WHERE inventory.items.item_id = _item_id
	AND NOT inventory.items.deleted;

    RETURN QUERY
    SELECT * FROM inventory.get_associated_units(_unit_id);
END
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS inventory.get_associated_units_by_item_code(_item_code text);

CREATE FUNCTION inventory.get_associated_units_by_item_code(_item_code text)
RETURNS TABLE
(
    unit_id integer, 
    unit_code text, 
    unit_name text
)
AS
$$
    DECLARE _unit_id integer;
BEGIN
    SELECT inventory.items.unit_id INTO _unit_id
    FROM inventory.items
    WHERE LOWER(item_code) = LOWER(_item_code)
	AND NOT inventory.items.deleted;

    RETURN QUERY
    SELECT * FROM inventory.get_associated_units(_unit_id);
END
$$
LANGUAGE plpgsql;

