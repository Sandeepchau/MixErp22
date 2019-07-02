DROP FUNCTION IF EXISTS inventory.get_item_cost_price(_item_id integer, _unit_id integer);

CREATE FUNCTION inventory.get_item_cost_price(_item_id integer, _unit_id integer)
RETURNS public.money_strict2
STABLE
AS
$$
    DECLARE _price              public.money_strict2;
    DECLARE _costing_unit_id    integer;
    DECLARE _factor             numeric(30, 6);
  
BEGIN    
    SELECT 
        cost_price, 
        unit_id
    INTO 
        _price, 
        _costing_unit_id
    FROM inventory.items
    WHERE inventory.items.item_id = _item_id
	AND NOT inventory.items.deleted;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    _factor := inventory.convert_unit(_unit_id, _costing_unit_id);
    RETURN _price * _factor;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_item_cost_price(6, 7);
