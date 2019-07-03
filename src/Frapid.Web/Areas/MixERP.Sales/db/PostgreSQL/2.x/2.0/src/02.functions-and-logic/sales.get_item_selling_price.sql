DROP FUNCTION IF EXISTS sales.get_item_selling_price(_office_id integer, _item_id integer, _customer_type_id integer, _price_type_id integer, _unit_id integer);

CREATE FUNCTION sales.get_item_selling_price(_office_id integer, _item_id integer, _customer_type_id integer, _price_type_id integer, _unit_id integer)
RETURNS public.money_strict2
AS
$$
    DECLARE _price              public.money_strict2;
    DECLARE _costing_unit_id    integer;
    DECLARE _factor             numeric(30, 6);
    DECLARE _tax_rate           numeric(30, 6);
    DECLARE _includes_tax       boolean;
    DECLARE _tax                public.money_strict2;
BEGIN

    --Fist pick the catalog price which matches all these fields:
    --Item, Customer Type, Price Type, and Unit.
    --This is the most effective price.
    SELECT 
        item_selling_prices.price, 
        item_selling_prices.unit_id,
        item_selling_prices.includes_tax
    INTO 
        _price, 
        _costing_unit_id,
        _includes_tax       
    FROM sales.item_selling_prices
    WHERE item_selling_prices.item_id=_item_id
    AND item_selling_prices.customer_type_id=_customer_type_id
    AND item_selling_prices.price_type_id =_price_type_id
    AND item_selling_prices.unit_id = _unit_id
	AND NOT sales.item_selling_prices.deleted;

    IF(_costing_unit_id IS NULL) THEN
        --We do not have a selling price of this item for the unit supplied.
        --Let's see if this item has a price for other units.
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.customer_type_id=_customer_type_id
        AND item_selling_prices.price_type_id =_price_type_id
		AND NOT sales.item_selling_prices.deleted;
    END IF;

    IF(_price IS NULL) THEN
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.price_type_id =_price_type_id
		AND NOT sales.item_selling_prices.deleted;
    END IF;

    
    IF(_price IS NULL) THEN
        --This item does not have selling price defined in the catalog.
        --Therefore, getting the default selling price from the item definition.
        SELECT 
            selling_price, 
            unit_id,
            false
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM inventory.items
        WHERE inventory.items.item_id = _item_id
		AND NOT inventory.items.deleted;
    END IF;

    IF(_includes_tax) THEN
        _tax_rate := finance.get_sales_tax_rate(_office_id);
        _price := _price / ((100 + _tax_rate)/ 100);
    END IF;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    _factor := inventory.convert_unit(_unit_id, _costing_unit_id);

    RETURN _price * _factor;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.get_item_selling_price(1, 1, 1, 1, 1);
