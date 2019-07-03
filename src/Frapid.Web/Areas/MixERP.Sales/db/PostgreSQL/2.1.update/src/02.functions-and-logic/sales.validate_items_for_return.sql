DROP FUNCTION IF EXISTS sales.validate_items_for_return
(
    _transaction_master_id                  bigint, 
    _details                                sales.sales_detail_type[]
);

CREATE FUNCTION sales.validate_items_for_return
(
    _transaction_master_id                  bigint, 
    _details                                sales.sales_detail_type[]
)
RETURNS TABLE
(
    is_valid                                boolean,
    error_message                           national character varying(2000)
)
AS
$$
    DECLARE _checkout_id                    bigint = 0;
    DECLARE _item_id                        integer = 0;
    DECLARE _factor_to_base_unit            numeric(30, 6);
    DECLARE _returned_in_previous_batch     numeric(30, 6) = 0;
    DECLARE _in_verification_queue          numeric(30, 6) = 0;
    DECLARE _actual_price_in_root_unit      numeric(30, 6) = 0;
    DECLARE _price_in_root_unit             numeric(30, 6) = 0;
    DECLARE _item_in_stock                  numeric(30, 6) = 0;
    DECLARE _error_item_id                  integer;
    DECLARE _error_quantity                 numeric(30, 6);
    DECLARE _error_unit						national character varying(500);
    DECLARE _error_amount                   numeric(30, 6);
    DECLARE _total_rows                     integer = 0;
    DECLARE this                            RECORD;
BEGIN        
    _checkout_id                            := inventory.get_checkout_id_by_transaction_master_id(_transaction_master_id);

    DROP TABLE IF EXISTS _result;
    CREATE TEMPORARY TABLE _result
    (
        is_valid                                boolean,
        error_message                           national character varying(2000)
    ) ON COMMIT DROP;
    
    INSERT INTO _result(is_valid, "error_message")
    SELECT false, '';

    DROP TABLE IF EXISTS _details_temp;
    CREATE TEMPORARY TABLE _details_temp
    (
        id                  SERIAL,
        store_id            integer,
        item_id             integer,
        item_in_stock       numeric(30, 6),
        quantity            numeric(30, 6),        
        unit_id             integer,
        price               numeric(30, 6),
        discount_rate       numeric(30, 6),
        discount			numeric(30, 6),
        is_taxed			boolean,
        shipping_charge     numeric(30, 6),
        root_unit_id        integer,
        base_quantity       numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _details_temp(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
    FROM explode_array(_details);

    UPDATE _details_temp
    SET 
        item_in_stock = inventory.count_item_in_stock(item_id, unit_id, store_id);
       
    UPDATE _details_temp
    SET root_unit_id = inventory.get_root_unit_id(unit_id);

    UPDATE _details_temp
    SET base_quantity = inventory.convert_unit(unit_id, root_unit_id) * quantity;


    --Determine whether the quantity of the returned item(s) is less than or equal to the same on the actual transaction
    DROP TABLE IF EXISTS _item_summary;
    CREATE TEMPORARY TABLE _item_summary
    (
        store_id                    integer,
        item_id                     integer,
        root_unit_id                integer,
        returned_quantity           numeric(30, 6),
        actual_quantity             numeric(30, 6),
        returned_in_previous_batch  numeric(30, 6),
        in_verification_queue       numeric(30, 6)
    ) ON COMMIT DROP;
    
    INSERT INTO _item_summary(store_id, item_id, root_unit_id, returned_quantity)
    SELECT
        store_id,
        item_id,
        root_unit_id, 
        SUM(base_quantity)
    FROM _details_temp
    GROUP BY 
        store_id, 
        item_id,
        root_unit_id;

    UPDATE _item_summary
    SET 
        actual_quantity = 
        (
            SELECT SUM(base_quantity)
            FROM inventory.checkout_details
            WHERE inventory.checkout_details.checkout_id = _checkout_id
            AND inventory.checkout_details.item_id = item_summary.item_id
        )
    FROM _item_summary AS item_summary;

    UPDATE _item_summary
    SET 
        returned_in_previous_batch = 
        (
            SELECT 
                COALESCE(SUM(base_quantity), 0)
            FROM inventory.checkout_details
            WHERE checkout_id IN
            (
                SELECT checkout_id
                FROM inventory.checkouts
                INNER JOIN finance.transaction_master
                ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
                WHERE finance.transaction_master.verification_status_id > 0
                AND inventory.checkouts.transaction_master_id IN 
                (
                    SELECT 
                        return_transaction_master_id 
                    FROM sales.returns
                    WHERE transaction_master_id = _transaction_master_id
                )
            )
            AND item_id = item_summary.item_id
        )
    FROM _item_summary AS item_summary;

    UPDATE _item_summary
    SET 
        in_verification_queue =
        (
            SELECT 
                COALESCE(SUM(base_quantity), 0)
            FROM inventory.checkout_details
            WHERE checkout_id IN
            (
                SELECT checkout_id
                FROM inventory.checkouts
                INNER JOIN finance.transaction_master
                ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
                WHERE finance.transaction_master.verification_status_id = 0
                AND inventory.checkouts.transaction_master_id IN 
                (
                    SELECT 
                    return_transaction_master_id 
                    FROM sales.returns
                    WHERE transaction_master_id = _transaction_master_id
                )
            )
            AND item_id = item_summary.item_id
        )
    FROM _item_summary AS item_summary;
    
    --Determine whether the price of the returned item(s) is less than or equal to the same on the actual transaction
    DROP TABLE IF EXISTS _cumulative_pricing;
    CREATE TEMPORARY TABLE _cumulative_pricing
    (
        item_id                     integer,
        base_price                  numeric(30, 6),
        allowed_returns             numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _cumulative_pricing
    SELECT
        item_id,
        MIN(price  / base_quantity * quantity) as base_price,
        SUM(base_quantity) OVER(ORDER BY item_id, base_quantity) as allowed_returns
    FROM inventory.checkout_details 
    WHERE checkout_id = _checkout_id
    GROUP BY item_id, base_quantity;

    IF EXISTS(SELECT 0 FROM _details_temp WHERE store_id IS NULL OR store_id <= 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            error_message = 'Invalid store.';

        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    IF EXISTS(SELECT 0 FROM _details_temp WHERE item_id IS NULL OR item_id <= 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid item.';
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    IF EXISTS(SELECT 0 FROM _details_temp WHERE unit_id IS NULL OR unit_id <= 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid unit.';
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    IF EXISTS(SELECT 0 FROM _details_temp WHERE quantity IS NULL OR quantity <= 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid quantity.';
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    IF(_checkout_id  IS NULL OR _checkout_id  <= 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid transaction id.';
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    IF NOT EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE transaction_master_id = _transaction_master_id
        AND verification_status_id > 0
    ) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid or rejected transaction.' ;
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;
        
    SELECT item_id INTO _item_id
    FROM _details_temp
    WHERE item_id NOT IN
    (
        SELECT item_id FROM inventory.checkout_details
        WHERE checkout_id = _checkout_id
    );

    IF(COALESCE(_item_id, 0) != 0) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = FORMAT('The item %s is not associated with this transaction.', inventory.get_item_name_by_item_id(_item_id));

        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;


    IF NOT EXISTS
    (
        SELECT 0 FROM inventory.checkout_details
        INNER JOIN _details_temp AS _details_temp
        ON inventory.checkout_details.item_id = _details_temp.item_id
        WHERE checkout_id = _checkout_id
        AND inventory.get_root_unit_id(_details_temp.unit_id) = inventory.get_root_unit_id(inventory.checkout_details.unit_id)
        LIMIT 1
    ) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = 'Invalid or incompatible unit specified.';
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    SELECT
        item_id,
        returned_quantity,
		inventory.get_unit_name_by_unit_id(root_unit_id)
    INTO
        _error_item_id,
        _error_quantity,
		_error_unit
    FROM _item_summary
    WHERE returned_quantity + returned_in_previous_batch + in_verification_queue > actual_quantity
    LIMIT 1;

    IF(_error_item_id IS NOT NULL) THEN
        UPDATE _result 
        SET 
            is_valid = false, 
            "error_message" = FORMAT('The returned quantity (%s %s) of %s is greater than actual quantity.', CAST(_error_quantity AS varchar(30)), _error_unit, inventory.get_item_name_by_item_id(_error_item_id));
        RETURN QUERY
        SELECT * FROM _result;
        RETURN;
    END IF;

    SELECT MAX(id) INTO _total_rows FROM _details_temp;
    FOR this IN
    SELECT item_id, base_quantity, (price / base_quantity * quantity)::numeric(30, 6) as price
    FROM _details_temp
    LOOP
        SELECT
            item_id,
            base_price
        INTO
            _error_item_id,
            _error_amount
        FROM _cumulative_pricing
        WHERE item_id = this.item_id
        AND base_price <  this.price
        AND allowed_returns >= this.base_quantity
        LIMIT 1;
        
        IF (_error_item_id IS NOT NULL) THEN
            UPDATE _result 
            SET 
                is_valid = false, 
                "error_message" = FORMAT
                                    (
                                        'The returned base amount %s of %s cannot be greater than actual amount %s.', 
                                        this.price, 
                                        inventory.get_item_name_by_item_id(_error_item_id), 
                                        CAST(_error_amount AS varchar(30))
                                    );
            RETURN QUERY
            SELECT * FROM _result;
            RETURN;
        END IF;
    END LOOP;

    UPDATE _result 
    SET 
        is_valid = true, 
        "error_message" = '';
    RETURN QUERY
    SELECT * FROM _result;
    RETURN;
END
$$
LANGUAGE plpgsql;
-- 
-- SELECT * FROM sales.validate_items_for_return
-- (
--     1058,
--     ARRAY[
--         ROW(1, 'Dr', 24, 1, 1,110000, 5000, 50, 0, true)::sales.sales_detail_type
--     ]
-- );
-- 
