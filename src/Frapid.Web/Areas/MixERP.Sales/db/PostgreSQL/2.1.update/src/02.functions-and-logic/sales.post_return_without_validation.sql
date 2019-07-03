DROP FUNCTION IF EXISTS sales.post_return_without_validation
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _value_date                             date,
    _book_date                              date,
    _store_id                               integer,
    _counter_id                             integer,
    _customer_id                            integer,
    _price_type_id                          integer,
    _reference_number                       national character varying(24),
    _statement_reference                    national character varying(2000),
    _details                                sales.sales_detail_type[],
	_shipper_id						        integer,
	_discount						        numeric(30, 6)
);

CREATE FUNCTION sales.post_return_without_validation
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _value_date                             date,
    _book_date                              date,
    _store_id                               integer,
    _counter_id                             integer,
    _customer_id                            integer,
    _price_type_id                          integer,
    _reference_number                       national character varying(24),
    _statement_reference                    national character varying(2000),
    _details                                sales.sales_detail_type[],
	_shipper_id						        integer,
	_discount						        numeric(30, 6)
)
RETURNS bigint
AS
$$
    DECLARE _book_name						national character varying(50) = 'Sales Return';
    DECLARE _cost_center_id					bigint;
    DECLARE _tran_counter					integer;
    DECLARE _tran_code						national character varying(50);
    DECLARE _checkout_id					bigint;
    DECLARE _grand_total					numeric(30, 6);
    DECLARE _discount_total					numeric(30, 6);
    DECLARE _default_currency_code			national character varying(12);
    DECLARE _tax_total						numeric(30, 6);
    DECLARE _tax_account_id					integer;
	DECLARE _sales_tax_rate					numeric(30, 6);
	DECLARE _taxable_total					numeric(30, 6);
	DECLARE _nontaxable_total				numeric(30, 6);
    DECLARE _invoice_discount				numeric(30, 6);
    DECLARE _shipping_charge                numeric(30, 6);
    DECLARE _payable						numeric(30, 6);
    DECLARE _transaction_code               national character varying(50);
    DECLARE _is_periodic                    boolean = inventory.is_periodic_inventory(_office_id);
	DECLARE _transaction_master_id			bigint;
    DECLARE _cost_of_goods                  numeric(30, 6);
BEGIN
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book_name, _value_date) THEN
        RETURN 0;
    END IF;

    DROP TABLE IF EXISTS _checkout_details;
    CREATE TEMPORARY TABLE _checkout_details
    (
        id                                  SERIAL PRIMARY KEY,
        checkout_id                         bigint, 
        store_id                            integer,
        transaction_type                    national character varying(2),
        item_id                             integer, 
        quantity                            numeric(30, 6),
        unit_id                             integer,
        base_quantity                       numeric(30, 6),
        base_unit_id                        integer,
        price                               numeric(30, 6) NOT NULL DEFAULT(0),
        cost_of_goods_sold                  numeric(30, 6) NOT NULL DEFAULT(0),
        discount_rate                       numeric(30, 6),
        discount                            numeric(30, 6) NOT NULL DEFAULT(0),
		is_taxable_item						boolean,
		is_taxed							boolean,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6) NOT NULL DEFAULT(0),
        sales_account_id					integer, 
        sales_discount_account_id			integer, 
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    ) ON COMMIT DROP;

    DROP TABLE IF EXISTS _temp_transaction_details;
    CREATE TEMPORARY TABLE _temp_transaction_details
    (
        transaction_master_id               bigint, 
        tran_type                           national character varying(4), 
        account_id                          integer, 
        statement_reference                 national character varying(2000), 
        currency_code                       national character varying(12), 
        amount_in_currency                  numeric(30, 6), 
        local_currency_code                 national character varying(12), 
        er                                  numeric(30, 6), 
        amount_in_local_currency            numeric(30, 6)
    ) ON COMMIT DROP;

        
    _tax_account_id                         := finance.get_sales_tax_account_id_by_office_id(_office_id);

    IF(COALESCE(_customer_id, 0) = 0) THEN
        RAISE EXCEPTION 'Invalid customer';
    END IF;
    


    SELECT finance.tax_setups.sales_tax_rate
    INTO _sales_tax_rate
    FROM finance.tax_setups
    WHERE NOT finance.tax_setups.deleted
    AND finance.tax_setups.office_id = _office_id;

    INSERT INTO _checkout_details(store_id, transaction_type, item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, is_taxed)
    SELECT store_id, 'Cr', item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, COALESCE(is_taxed, true)
    FROM explode_array(_details);

    UPDATE _checkout_details 
    SET
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id),
        sales_account_id				= inventory.get_sales_account_id(item_id),
        sales_discount_account_id		= inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);
    
    UPDATE _checkout_details
    SET
        discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
    WHERE COALESCE(discount, 0) = 0;

    UPDATE _checkout_details
    SET
        discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
    WHERE COALESCE(discount_rate, 0) = 0;


    UPDATE _checkout_details
    SET is_taxable_item = is_taxed;

    UPDATE _checkout_details
    SET is_taxed = false
    WHERE NOT is_taxable_item;

    UPDATE _checkout_details
    SET amount = (COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0);

    IF EXISTS
    (
        SELECT 1
        FROM _checkout_details
        WHERE amount < 0
    ) THEN
        RAISE EXCEPTION 'A line amount cannot be less than zero.';
    END IF;

    IF EXISTS
    (
        SELECT 0 FROM _checkout_details AS details
        WHERE NOT inventory.is_valid_unit_id(details.unit_id, details.item_id)
        LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Item/unit mismatch.';
    END IF;

    SELECT 
        COALESCE(SUM(CASE WHEN is_taxed THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
        COALESCE(SUM(CASE WHEN NOT is_taxed THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
    INTO
        _taxable_total,
        _nontaxable_total
    FROM _checkout_details;

    IF(_invoice_discount > _taxable_total) THEN
        RAISE EXCEPTION 'The invoice discount cannot be greater than total taxable amount.';
    END IF;


    SELECT 
        ROUND(SUM(COALESCE(discount, 0)), 2)
    INTO
        _discount_total  
    FROM _checkout_details;


    SELECT SUM(COALESCE(shipping_charge, 0))    INTO _shipping_charge FROM _checkout_details;

    _tax_total                          := ROUND((COALESCE(_taxable_total, 0) - COALESCE(_invoice_discount, 0)) * (_sales_tax_rate / 100), 2);
    _grand_total					    := COALESCE(_taxable_total, 0) + COALESCE(_nontaxable_total, 0) + COALESCE(_tax_total, 0)  - COALESCE(_invoice_discount, 0);
    _payable						    := _grand_total;


    _default_currency_code              := core.get_currency_code_by_office_id(_office_id);
    _tran_counter                       := finance.get_new_transaction_counter(_value_date);
    _transaction_code                   := finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);


    INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', sales_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM _checkout_details
    GROUP BY sales_account_id;

    IF(NOT _is_periodic) THEN
        --Perpetutal Inventory Accounting System
        UPDATE _checkout_details 
        SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);


        SELECT SUM(cost_of_goods_sold)
        INTO _cost_of_goods
        FROM _checkout_details;


        IF(_cost_of_goods > 0) THEN
            INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', cost_of_goods_sold_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM _checkout_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', inventory_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM _checkout_details
            GROUP BY inventory_account_id;
        END IF;
    END IF;

    IF(COALESCE(_tax_total, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', _tax_account_id, _statement_reference, _default_currency_code, _tax_total, 1, _default_currency_code, _tax_total;
    END IF;

    IF(COALESCE(_shipping_charge, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', inventory.get_account_id_by_shipper_id(_shipper_id), _statement_reference, _default_currency_code, _shipping_charge, 1, _default_currency_code, _shipping_charge;
    END IF;


    IF(COALESCE(_discount_total, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', sales_discount_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(discount, 0)), 1, _default_currency_code, SUM(COALESCE(discount, 0))
        FROM _checkout_details
        GROUP BY sales_discount_account_id
        HAVING SUM(COALESCE(discount, 0)) > 0;
    END IF;


    INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', inventory.get_account_id_by_customer_id(_customer_id), _statement_reference, _default_currency_code, _payable, 1, _default_currency_code, _payable;
    
    IF
    (
        SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
        FROM _temp_transaction_details
    ) != 0 THEN
        RAISE EXCEPTION E'Could not balance the Journal Entry. Nothing was saved.\n %', array_to_string(array_agg(_temp_transaction_details), E'\n') FROM _temp_transaction_details;		
    END IF;
    

    INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT _tran_counter, _transaction_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference
    RETURNING finance.transaction_master.transaction_master_id INTO _transaction_master_id;
    
    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT _value_date, _book_date, _office_id, _transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM _temp_transaction_details
    ORDER BY tran_type DESC;


    INSERT INTO inventory.checkouts(value_date, book_date, transaction_master_id, transaction_book, posted_by, shipper_id, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
    SELECT _value_date, _book_date, _transaction_master_id, _book_name, _user_id, _shipper_id, _office_id, _invoice_discount, _taxable_total, _sales_tax_rate, _tax_total, _nontaxable_total
    RETURNING inventory.checkouts.checkout_id INTO _checkout_id;


    INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity)
    SELECT _checkout_id, _value_date, _book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity
    FROM _checkout_details;
    

    PERFORM finance.auto_verify(_transaction_master_id, _office_id);


    INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
    SELECT NULL, _checkout_id, NULL, _transaction_master_id, _counter_id, _customer_id, _price_type_id;

    RETURN _transaction_master_id;
END;
$$
LANGUAGE plpgsql;



-- SELECT * FROM sales.post_return_without_validation
-- (
--     1, --_office_id                              integer,
--     1, --_user_id                                integer,
--     1, --_login_id                               bigint,
--     finance.get_value_date(1), --_value_date                             date,
--     finance.get_value_date(1), --_book_date                              date,
--     1, --_store_id                               integer,
--     1, --_counter_id                             integer,
--     1, --_customer_id                            integer,
--     1, --_price_type_id                          integer,
--     '',--_reference_number                       national character varying(24),
--     '',--_statement_reference                    national character varying(2000),
--     ARRAY
--     [
--         ROW(1, 'Dr', 1, 1, 1,1, 0, 10, 200, false)::sales.sales_detail_type,
--         ROW(1, 'Dr', 2, 1, 7,1, 300, 10, 30, false)::sales.sales_detail_type,
--         ROW(1, 'Dr', 3, 1, 1,1, 5000, 10, 50, false)::sales.sales_detail_type
--     ],
-- 	1, --_shipper_id						        integer,
-- 	10 --_discount						        numeric(30, 6)
-- );
