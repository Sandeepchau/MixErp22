DROP FUNCTION IF EXISTS inventory.get_write_off_cost_of_goods_sold(_checkout_id bigint, _item_id integer, _unit_id integer, _quantity integer);

CREATE FUNCTION inventory.get_write_off_cost_of_goods_sold(_checkout_id bigint, _item_id integer, _unit_id integer, _quantity integer)
RETURNS money_strict2
AS
$$
    DECLARE _base_unit_id integer;
    DECLARE _factor numeric(30, 6);
BEGIN
    _base_unit_id    = inventory.get_root_unit_id(_unit_id);
    _factor          = inventory.convert_unit(_unit_id, _base_unit_id);


    RETURN
        SUM((cost_of_goods_sold / base_quantity) * _factor * _quantity)     
         FROM inventory.checkout_details
    WHERE checkout_id = _checkout_id
    AND item_id = _item_id;    
END
$$
LANGUAGE plpgsql;


--SELECT * FROM inventory.get_write_off_cost_of_goods_sold(7, 3, 1, 1);
