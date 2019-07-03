DROP FUNCTION IF EXISTS sales.post_sales
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _counter_id                             integer,
    _value_date                             date,
    _book_date                              date,
    _cost_center_id                         integer,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _tender                                 public.money_strict2,
    _change                                 public.money_strict2,
    _payment_term_id                        integer,
    _check_amount                           public.money_strict2,
    _check_bank_name                        national character varying(1000),
    _check_number                           national character varying(100),
    _check_date                             date,
    _gift_card_number                       national character varying(100),
    _customer_id                            integer,
    _price_type_id                          integer,
    _shipper_id                             integer,
    _store_id                               integer,
    _coupon_code                            national character varying(100),
    _is_flat_discount                       boolean,
    _discount                               public.money_strict2,
    _details                                sales.sales_detail_type[],
    _sales_quotation_id                     bigint,
    _sales_order_id                         bigint,
    _serial_number_ids                      text,
    _book_name                              national character varying(48)
);


CREATE FUNCTION sales.post_sales
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _counter_id                             integer,
    _value_date                             date,
    _book_date                              date,
    _cost_center_id                         integer,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _tender                                 public.money_strict2,
    _change                                 public.money_strict2,
    _payment_term_id                        integer,
    _check_amount                           public.money_strict2,
    _check_bank_name                        national character varying(1000),
    _check_number                           national character varying(100),
    _check_date                             date,
    _gift_card_number                       national character varying(100),
    _customer_id                            integer,
    _price_type_id                          integer,
    _shipper_id                             integer,
    _store_id                               integer,
    _coupon_code                            national character varying(100),
    _is_flat_discount                       boolean,
    _discount                               public.money_strict2,
    _details                                sales.sales_detail_type[],
    _sales_quotation_id                     bigint,
    _sales_order_id                         bigint,
    _serial_number_ids                      text,
    _book_name                              national character varying(48) DEFAULT 'Sales Entry'
)
RETURNS bigint
AS
$$
    DECLARE _transaction_master_id          bigint;
    DECLARE _checkout_id                    bigint;
    DECLARE _grand_total                    public.money_strict;
    DECLARE _discount_total                 public.money_strict2;
    DECLARE _receivable                     public.money_strict2;
    DECLARE _default_currency_code          national character varying(12);
    DECLARE _is_periodic                    boolean = inventory.is_periodic_inventory(_office_id);
    DECLARE _cost_of_goods                  public.money_strict;
    DECLARE _tran_counter                   integer;
    DECLARE _transaction_code               text;
    DECLARE _tax_total                      public.money_strict2;
    DECLARE _shipping_charge                public.money_strict2;
    DECLARE _cash_repository_id             integer;
    DECLARE _cash_account_id                integer;
    DECLARE _is_cash                        boolean = false;
    DECLARE _is_credit                      boolean = false;
    DECLARE _gift_card_id                   integer;
    DECLARE _gift_card_balance              numeric(30, 6);
    DECLARE _coupon_id                      integer;
    DECLARE _coupon_discount                numeric(30, 6); 
    DECLARE _default_discount_account_id    integer;
    DECLARE _fiscal_year_code               national character varying(12);
    DECLARE _invoice_number                 bigint;
    DECLARE _tax_account_id                 integer;
    DECLARE _receipt_transaction_master_id  bigint;
    DECLARE _sales_tax_rate                 numeric(30, 6);
    DECLARE this                            RECORD;
	DECLARE _taxable_total					numeric(30, 6);
	DECLARE _nontaxable_total				numeric(30, 6);
    DECLARE _sales_discount_account_id      integer;
    DECLARE _sql                            text;
BEGIN        
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book_name, _value_date) THEN
        RETURN 0;
    END IF;

    DROP TABLE IF EXISTS _checkout_details;
    CREATE TEMPORARY TABLE _checkout_details
    (
        id                                  SERIAL PRIMARY KEY,
        checkout_id                         bigint, 
        tran_type                           national character varying(2), 
        store_id                            integer,
        item_id                             integer, 
        quantity                            numeric(30, 6),        
        unit_id                             integer,
        base_quantity                       numeric(30, 6),
        base_unit_id                        integer,                
        price                               numeric(30, 6),
        cost_of_goods_sold                  numeric(30, 6) DEFAULT(0),
        discount_rate                       numeric(30, 6),
        discount                            numeric(30, 6),
		is_taxed							boolean,
		is_taxable_item						boolean,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6),
        sales_account_id                    integer,
        sales_discount_account_id           integer,
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    ) ON COMMIT DROP;

    DROP TABLE IF EXISTS _item_quantities;
    CREATE TEMPORARY TABLE _item_quantities
    (
        item_id                             integer,
        base_unit_id                        integer,
        store_id                            integer,
        total_sales                         numeric(30, 6),
        in_stock                            numeric(30, 6),
        maintain_inventory                  boolean
    ) ON COMMIT DROP;

    DROP TABLE IF EXISTS _temp_transaction_details;
    CREATE TEMPORARY TABLE _temp_transaction_details
    (
        transaction_master_id               bigint, 
        tran_type                           national character varying(2), 
        account_id                          integer NOT NULL, 
        statement_reference                 national character varying(2000), 
        cash_repository_id                  integer, 
        currency_code                       national character varying(12), 
        amount_in_currency                  numeric(30, 6) NOT NULL, 
        local_currency_code                 national character varying(12), 
        er                                  numeric(30, 6), 
        amount_in_local_currency			numeric(30, 6)
    ) ON COMMIT DROP;

    _tax_account_id                         := finance.get_sales_tax_account_id_by_office_id(_office_id);
    _default_currency_code                  := core.get_currency_code_by_office_id(_office_id);
    _cash_account_id                        := inventory.get_cash_account_id_by_store_id(_store_id);
    _cash_repository_id                     := inventory.get_cash_repository_id_by_store_id(_store_id);
    _is_cash                                := finance.is_cash_account_id(_cash_account_id);    

    _coupon_id                              := sales.get_active_coupon_id_by_coupon_code(_coupon_code);
    _gift_card_id                           := sales.get_gift_card_id_by_gift_card_number(_gift_card_number);
    _gift_card_balance                      := sales.get_gift_card_balance(_gift_card_id, _value_date);


    
    SELECT finance.fiscal_year.fiscal_year_code
    INTO _fiscal_year_code
    FROM finance.fiscal_year
    WHERE _value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on
    LIMIT 1;

    IF(COALESCE(_customer_id, 0) = 0) THEN
        RAISE EXCEPTION 'Please select a customer.';
    END IF;

    IF(COALESCE(_coupon_code, '') != '' AND COALESCE(_discount, 0) > 0) THEN
        RAISE EXCEPTION 'Please do not specify discount rate when you mention coupon code.';
    END IF;


    IF(COALESCE(_payment_term_id, 0) > 0) THEN
        _is_credit                          := true;
    END IF;

    IF(NOT _is_credit AND NOT _is_cash) THEN
        RAISE EXCEPTION 'Cannot post sales. Invalid cash account mapping on store.';
    END IF;


    IF(_is_cash) THEN
        _cash_repository_id                 := NULL;
    END IF;

    SELECT finance.tax_setups.sales_tax_rate
    INTO _sales_tax_rate
    FROM finance.tax_setups
    WHERE NOT finance.tax_setups.deleted
    AND finance.tax_setups.office_id = _office_id;

    INSERT INTO _checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
    FROM explode_array(_details);

    UPDATE _checkout_details 
    SET
        tran_type                       = 'Cr',
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id);

    UPDATE _checkout_details
    SET
        discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
    WHERE COALESCE(discount, 0) = 0;

    UPDATE _checkout_details
    SET
        discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
    WHERE COALESCE(discount_rate, 0) = 0;


    UPDATE _checkout_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

    UPDATE _checkout_details
    SET is_taxable_item = is_taxed;

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

    INSERT INTO _item_quantities(item_id, base_unit_id, store_id, total_sales)
    SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
    FROM _checkout_details
    GROUP BY item_id, base_unit_id, store_id;

    UPDATE _item_quantities
    SET maintain_inventory = inventory.items.maintain_inventory
    FROM inventory.items
    WHERE _item_quantities.item_id = inventory.items.item_id;
    
    UPDATE _item_quantities
    SET in_stock = inventory.count_item_in_stock(item_id, base_unit_id, store_id)
    WHERE maintain_inventory;

    IF EXISTS
    (
        SELECT 0 FROM _item_quantities
        WHERE total_sales > in_stock
        AND maintain_inventory
        LIMIT 1        
    ) THEN
        RAISE EXCEPTION 'Insufficient item quantity';
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


    SELECT 
        ROUND(SUM(COALESCE(discount, 0)), 2)
    INTO
        _discount_total  
    FROM _checkout_details;

    SELECT 
        SUM(COALESCE(shipping_charge, 0)) 
    INTO
        _shipping_charge
    FROM _checkout_details;

    _coupon_discount                = ROUND(_discount, 2);

    IF(NOT _is_flat_discount AND COALESCE(_discount, 0) > 0) THEN
        _coupon_discount            = ROUND(COALESCE(_taxable_total, 0) * (_discount/100), 2);
    END IF;

    IF(_coupon_discount > _taxable_total) THEN
        RAISE EXCEPTION 'The coupon discount cannot be greater than total taxable amount.';
    END IF;


    _tax_total          := ROUND((COALESCE(_taxable_total, 0) - COALESCE(_coupon_discount, 0)) * (_sales_tax_rate / 100), 2);
    _grand_total        := COALESCE(_taxable_total, 0) + COALESCE(_nontaxable_total, 0) + COALESCE(_tax_total, 0) - COALESCE(_coupon_discount, 0);

    _receivable         = _grand_total;

    IF(_is_flat_discount AND _discount > _receivable) THEN
        RAISE EXCEPTION 'The discount amount % cannot be greater than total amount %.', _discount, _receivable;
    ELSIF(NOT _is_flat_discount AND _discount > 100) THEN
        RAISE EXCEPTION 'The discount rate cannot be greater than 100.';
    END IF;

   IF(_tender > 0) THEN
        IF(_tender < _receivable) THEN
            RAISE EXCEPTION 'The tender amount must be greater than or equal to %.', _receivable;
        END IF;
    ELSIF(_check_amount > 0) THEN
        IF(_check_amount < _receivable) THEN
            RAISE EXCEPTION 'The check amount must be greater than or equal to %.', _receivable;
        END IF;
    ELSIF(COALESCE(_gift_card_number, '') != '') THEN
        IF(_gift_card_balance < _receivable) THEN
            RAISE EXCEPTION 'The gift card must have a balance of at least %s.', _receivable;
        END IF;
    END IF;
    
    INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', sales_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
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
            SELECT 'Dr', cost_of_goods_sold_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM _checkout_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM _checkout_details
            GROUP BY inventory_account_id;
        END IF;
    END IF;

    IF(COALESCE(_tax_total, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', _tax_account_id, _statement_reference, _default_currency_code, _tax_total, 1, _default_currency_code, _tax_total;
    END IF;

    IF(COALESCE(_shipping_charge, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_shipper_id(_shipper_id), _statement_reference, _default_currency_code, _shipping_charge, 1, _default_currency_code, _shipping_charge;                
    END IF;


    IF(COALESCE(_discount_total, 0) > 0) THEN
        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_discount_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(discount, 0)), 1, _default_currency_code, SUM(COALESCE(discount, 0))
        FROM _checkout_details
        GROUP BY sales_discount_account_id
        HAVING SUM(COALESCE(discount, 0)) > 0;
    END IF;

    IF(COALESCE(_coupon_discount, 0) > 0) THEN
        SELECT inventory.stores.sales_discount_account_id 
        INTO _sales_discount_account_id
        FROM inventory.stores
        WHERE inventory.stores.store_id = _store_id;

        INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', _sales_discount_account_id, _statement_reference, _default_currency_code, _coupon_discount, 1, _default_currency_code, _coupon_discount;
    END IF;

    INSERT INTO _temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', inventory.get_account_id_by_customer_id(_customer_id), _statement_reference, _default_currency_code, _receivable, 1, _default_currency_code, _receivable;
    
    IF
    (
        SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
        FROM _temp_transaction_details
    ) != 0  THEN
    RAISE EXCEPTION E'Could not balance the Journal Entry. Nothing was saved.\n %', array_to_string(array_agg(_temp_transaction_details), E'\n') FROM _temp_transaction_details;		
    END IF;
    

    _tran_counter           = finance.get_new_transaction_counter(_value_date);
    _transaction_code       = finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

    
    RAISE INFO E'Journal entry.\n %', array_to_string(array_agg(_temp_transaction_details), E'\n') FROM _temp_transaction_details;		
    INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT _tran_counter, _transaction_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference
    RETURNING transaction_master_id INTO _transaction_master_id;

    UPDATE _temp_transaction_details
    SET transaction_master_id   = _transaction_master_id;

    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT _value_date, _book_date, _office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM _temp_transaction_details
    ORDER BY tran_type DESC;

    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, shipper_id, posted_by, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
    SELECT _book_name, _value_date, _book_date, _transaction_master_id, _shipper_id, _user_id, _office_id, _coupon_discount, _taxable_total, _sales_tax_rate, _tax_total, _nontaxable_total
    RETURNING checkout_id INTO _checkout_id;
    
    UPDATE _checkout_details
    SET checkout_id             = _checkout_id;

    INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount_rate, discount, shipping_charge, is_taxed)
    SELECT _value_date, _book_date, checkout_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, COALESCE(cost_of_goods_sold, 0), discount_rate, discount, shipping_charge, is_taxable_item
    FROM _checkout_details;

    SELECT 
        COALESCE(MAX(invoice_number), 0) + 1
    INTO
        _invoice_number 
    FROM sales.sales
    WHERE sales.sales.fiscal_year_code = _fiscal_year_code;

    IF(NOT _is_credit AND _book_name = 'Sales Entry') THEN
        SELECT sales.post_receipt
        (
            _user_id, 
            _office_id, 
            _login_id,
            _customer_id,
            _default_currency_code, 
            1.0, 
            1.0,
            _reference_number, 
            _statement_reference, 
            _cost_center_id,
            _cash_account_id,
            _cash_repository_id,
            _value_date,
            _book_date,
            _receivable,
            _tender,
            _change,
            _check_amount,
            _check_bank_name,
            _check_number,
            _check_date,
            _gift_card_number,
            _store_id,
            _transaction_master_id--CASCADING TRAN ID
        )
        INTO _receipt_transaction_master_id;

        PERFORM finance.auto_verify(_receipt_transaction_master_id, _office_id);
        
        IF(COALESCE(_serial_number_ids, '') != '') THEN
            UPDATE inventory.serial_numbers 
            SET sales_transaction_id = _transaction_master_id
            WHERE serial_number_id IN
            (
                SELECT 
                    item::bigint 
                FROM regexp_split_to_table(_serial_number_ids, ',') AS item
            );
        END IF;
    ELSE
        PERFORM sales.settle_customer_due(_customer_id, _office_id);
    END IF;

    IF(_book_name = 'Sales Entry') THEN
        INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id, receipt_transaction_master_id)
        SELECT _fiscal_year_code, _invoice_number, _price_type_id, _counter_id, _receivable, _cash_repository_id, _sales_order_id, _sales_quotation_id, _transaction_master_id, _checkout_id, _customer_id, _user_id, _coupon_id, _is_flat_discount, _discount, _discount_total, _is_credit, _payment_term_id, _tender, _change, _check_number, _check_date, _check_bank_name, _check_amount, _gift_card_id, _receipt_transaction_master_id;
    END IF;
		        
    EXECUTE finance.auto_verify(_transaction_master_id, _office_id);

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;



-- SELECT * FROM sales.post_sales
-- (
--     1, --_office_id
--     1, --_user_id
--     1, --_login_id 
--     1, --_counter_id
--     finance.get_value_date(1), --_value_date
--     finance.get_value_date(1), --_book_date
--     1, --_cost_center_id
--     '',--_reference_number 
--     'Test', --_statement_reference
--     500000,--_tender
--     2000, --_change
--     null, --_payment_term_id
--     null, --_check_amount
--     null, --_check_bank_name
--     null, --_check_number
--     null, --_check_date
--     null, --_gift_card_number
--     inventory.get_customer_id_by_customer_code('JOTAY'), --_customer_id
--     1, --_price_type_id
--     1, --_shipper_id
--     1, --_store_id
--     null, --_coupon_code
--     true, --_is_flat_discount
--     0, --_discount
--     ARRAY
--     [
--         ROW(1, 'Dr', 1, 1, 1,1, 0, 10, 200, false)::sales.sales_detail_type,
--         ROW(1, 'Dr', 2, 1, 7,1, 300, 10, 30, false)::sales.sales_detail_type,
--         ROW(1, 'Dr', 3, 1, 1,1, 5000, 10, 50, false)::sales.sales_detail_type
--     ],
--     NULL, --_sales_quotation_id
--     NULL, --_sales_order_id
--     '' --_serial_number_ids
-- );
-- 
