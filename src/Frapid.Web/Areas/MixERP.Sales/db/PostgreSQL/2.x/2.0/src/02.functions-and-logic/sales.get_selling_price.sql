DROP FUNCTION IF EXISTS sales.get_selling_price(_office_id integer, _item_id integer, _customer_id integer, _price_type_id integer, _unit_id integer);

CREATE FUNCTION sales.get_selling_price(_office_id integer, _item_id integer, _customer_id integer, _price_type_id integer, _unit_id integer)
RETURNS numeric(30, 6)
AS
$$
    DECLARE _price              decimal(30, 6);
    DECLARE _costing_unit_id    integer;
    DECLARE _factor             decimal(30, 6);
    DECLARE _tax_rate           decimal(30, 6);
    DECLARE _includes_tax       boolean;
    DECLARE _tax                decimal(30, 6);
	DECLARE _customer_type_id	integer;
BEGIN	

	SELECT inventory.items.selling_price_includes_tax INTO _includes_tax
	FROM inventory.items
	WHERE inventory.items.item_id = _item_id;
	
	SELECT
		sales.customerwise_selling_prices.price,
		sales.customerwise_selling_prices.unit_id
    INTO
        _price,
        _costing_unit_id
	FROM sales.customerwise_selling_prices
	WHERE NOT sales.customerwise_selling_prices.deleted
	AND sales.customerwise_selling_prices.customer_id = _customer_id
	AND sales.customerwise_selling_prices.item_id = _item_id;

	IF(COALESCE(_price, 0) = 0) THEN
		RETURN sales.get_item_selling_price(_office_id, _item_id, inventory.get_customer_type_id_by_customer_id(_customer_id), _price_type_id, _unit_id);
	END IF;

    IF(_includes_tax = 1) THEN
        _tax_rate   := finance.get_sales_tax_rate(_office_id);
        _price      := _price / ((100 + _tax_rate)/ 100);
    END IF;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    _factor         := inventory.convert_unit(_unit_id, _costing_unit_id);

    RETURN _price * _factor;
END
$$
LANGUAGE plpgsql;


--SELECT sales.get_selling_price(1,1,1,1,6);
