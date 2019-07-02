DROP FUNCTION IF EXISTS inventory.get_cost_of_goods_sold(_item_id integer, _unit_id integer, _store_id integer, _quantity numeric(30, 6));

CREATE FUNCTION inventory.get_cost_of_goods_sold(_item_id integer, _unit_id integer, _store_id integer, _quantity numeric(30, 6))
RETURNS numeric(30, 6)
AS
$$
    DECLARE _backup_quantity            numeric(30, 6);
    DECLARE _base_quantity              numeric(30, 6);
    DECLARE _base_unit_id               integer;
    DECLARE _base_unit_cost             numeric(30, 6);
    DECLARE _total_sold                 integer;
    DECLARE _office_id                  integer = inventory.get_office_id_by_store_id(_store_id);
    DECLARE _method                     national character varying(1000) = inventory.get_cost_of_good_method(_office_id);
BEGIN
	IF(_quantity = 0) THEN
		RETURN 0;
	END IF;


    --backup base quantity in numeric(30, 6)
    _backup_quantity                    := inventory.get_base_quantity_by_unit_id(_unit_id, _quantity);
    --convert base quantity to whole number
    _base_quantity                      := CEILING(_backup_quantity);
    _base_unit_id                       := inventory.get_root_unit_id(_unit_id);
        
    IF(_method = 'MAVCO') THEN
        RETURN inventory.get_mavcogs(_item_id, _store_id, _base_quantity, 1.00);
    END IF;

	--GET THE SUM TOTAL QUANTITIES SOLD IN THIS STORE
    SELECT COALESCE(SUM(base_quantity), 0)
    INTO _total_sold
    FROM inventory.verified_checkout_details_view
    WHERE transaction_type='Cr'
    AND item_id = _item_id
	AND store_id = _store_id;

	IF(_method = 'FIFO') THEN
		WITH all_purchases
		AS
		(
			SELECT ROW_NUMBER() OVER(ORDER BY value_date, checkout_detail_id) AS id, *
			FROM inventory.verified_checkout_details_view
			WHERE item_id = _item_id
			AND store_id = _store_id
			AND transaction_type = 'Dr'
		), purchase_prices
		AS
		(
			SELECT
				(
					SELECT SUM(base_quantity)
					FROM all_purchases AS i
					WHERE  i.id <= v.id
				) AS total,
				*
			FROM all_purchases AS v
		)
		SELECT
            (purchase_prices.price * purchase_prices.quantity) / purchase_prices.base_quantity
        INTO
            _base_unit_cost
		FROM purchase_prices
		WHERE total > _total_sold
		ORDER BY total
		LIMIT 1;

		_base_unit_cost := _base_unit_cost * _base_quantity;		
	END IF;

	IF(_method = 'LIFO') THEN
		WITH all_purchases
		AS
		(
			SELECT ROW_NUMBER() OVER(ORDER BY value_date, checkout_detail_id) AS id, *
			FROM inventory.verified_checkout_details_view
			WHERE item_id = _item_id
			AND store_id = _store_id
			AND transaction_type = 'Dr'
		), purchase_prices
		AS
		(
			SELECT
				(
					SELECT SUM(base_quantity)
					FROM all_purchases AS i
					WHERE  i.id >= v.id
				) AS total,
				*
			FROM all_purchases AS v
		)
		SELECT
			(purchase_prices.price * purchase_prices.quantity) / purchase_prices.base_quantity
		INTO
            _base_unit_cost
		FROM purchase_prices
		WHERE total > _total_sold
		ORDER BY total
		LIMIT 1;

		_base_unit_cost := _base_unit_cost * _base_quantity;		
	END IF;

	IF(_base_unit_cost IS NULL) THEN
		_base_unit_cost := inventory.get_item_cost_price(_item_id, _base_unit_id) * _base_quantity;
	END IF;

    --APPLY numeric(30, 6) QUANTITY PROVISON
    _base_unit_cost := _base_unit_cost * (_backup_quantity / _base_quantity);


    RETURN _base_unit_cost;
END
$$
LANGUAGE plpgsql;


--SELECT inventory.get_cost_of_goods_sold(1, 1, 1, 1);


