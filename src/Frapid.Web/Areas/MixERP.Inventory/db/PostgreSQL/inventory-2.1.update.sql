-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
ALTER TABLE inventory.inventory_setup
ADD COLUMN IF NOT EXISTS validate_returns boolean NOT NULL DEFAULT(true);


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_associated_unit_list.sql --<--<--
CREATE OR REPLACE FUNCTION inventory.get_associated_unit_list(_any_unit_id integer)
RETURNS integer[]
VOLATILE
AS
$$
    DECLARE root_unit_id integer;
BEGIN
    DROP TABLE IF EXISTS temp_unit;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_unit(unit_id integer) ON COMMIT DROP; 
    
    SELECT inventory.get_root_unit_id(_any_unit_id) INTO root_unit_id;
    
    INSERT INTO temp_unit(unit_id) 
    SELECT root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM temp_unit
        WHERE temp_unit.unit_id=root_unit_id
    );
    
    WITH RECURSIVE cte(unit_id)
    AS
    (
         SELECT 
            compare_unit_id
         FROM 
            inventory.compound_units
         WHERE 
            base_unit_id = root_unit_id
		 AND deleted = 0

        UNION ALL

         SELECT
            units.compare_unit_id
         FROM 
            inventory.compound_units units
         INNER JOIN cte 
         ON cte.unit_id = units.base_unit_id
		 WHERE deleted = 0
    )
    
    INSERT INTO temp_unit(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM temp_unit
    WHERE temp_unit.unit_id IS NULL;
    
    RETURN ARRAY(SELECT temp_unit.unit_id FROM temp_unit);
END
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_associated_unit_list(1);

-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_associated_units.sql --<--<--
DROP FUNCTION IF EXISTS inventory.get_associated_units(_any_unit_id integer);

CREATE FUNCTION inventory.get_associated_units(_any_unit_id integer)
RETURNS TABLE
(
    unit_id integer, 
    unit_code text, 
    unit_name text
)
VOLATILE
AS
$$
    DECLARE root_unit_id integer;
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_unit(unit_id integer) ON COMMIT DROP; 
    
    SELECT inventory.get_root_unit_id(_any_unit_id) INTO root_unit_id;
    
    INSERT INTO temp_unit(unit_id) 
    SELECT root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM temp_unit
        WHERE temp_unit.unit_id=root_unit_id
    );
    
    WITH RECURSIVE cte(unit_id)
    AS
    (
         SELECT 
            compare_unit_id
         FROM 
            inventory.compound_units
         WHERE 
            base_unit_id = root_unit_id
		 AND deleted = 0
		 
        UNION ALL

         SELECT
            units.compare_unit_id
         FROM 
            inventory.compound_units units
         INNER JOIN cte 
         ON cte.unit_id = units.base_unit_id
		 WHERE deleted = 0
    )
    
    INSERT INTO temp_unit(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM temp_unit
    WHERE temp_unit.unit_id IS NULL;
    
    RETURN QUERY 
    SELECT 
        inventory.units.unit_id,
        inventory.units.unit_code::text,
        inventory.units.unit_name::text
    FROM
        inventory.units
    WHERE
        inventory.units.unit_id 
    IN
    (
        SELECT temp_unit.unit_id FROM temp_unit
    );
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_brand_id_by_brand_name.sql --<--<--
DROP FUNCTION IF EXISTS inventory.get_brand_id_by_brand_name(text);

CREATE FUNCTION inventory.get_brand_id_by_brand_name(text)
RETURNS integer
AS
$$
BEGIN
        RETURN brand_id
        FROM inventory.brands
        WHERE inventory.brands.brand_name=$1
		AND NOT inventory.brands.deleted;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_cost_of_goods_sold.sql --<--<--
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




-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_root_unit_id.sql --<--<--
DROP FUNCTION IF EXISTS inventory.get_root_unit_id(_any_unit_id integer);

CREATE FUNCTION inventory.get_root_unit_id(_any_unit_id integer)
RETURNS integer
AS
$$
    DECLARE root_unit_id integer;
BEGIN
    SELECT base_unit_id INTO root_unit_id
    FROM inventory.compound_units
    WHERE inventory.compound_units.compare_unit_id=_any_unit_id
	AND NOT inventory.compound_units.deleted;

    IF(root_unit_id IS NULL OR root_unit_id = _any_unit_id) THEN
        RETURN _any_unit_id;
    ELSE
        RETURN inventory.get_root_unit_id(root_unit_id);
    END IF; 
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_total_customer_due.sql --<--<--
DROP FUNCTION IF EXISTS inventory.get_total_customer_due(office_id integer, customer_id integer);

CREATE FUNCTION inventory.get_total_customer_due(office_id integer, customer_id integer)
RETURNS DECIMAL(24, 4)
AS
$$
    DECLARE _account_id                     integer         = inventory.get_account_id_by_customer_id($2);
    DECLARE _debit                          numeric(30, 6)  = 0;
    DECLARE _credit                         numeric(30, 6)  = 0;
    DECLARE _local_currency_code            national character varying(12) = core.get_currency_code_by_office_id($1); 
    DECLARE _base_currency_code             national character varying(12) = inventory.get_currency_code_by_customer_id($2);
    DECLARE _amount_in_local_currency       numeric(30, 6)= 0;
    DECLARE _amount_in_base_currency        numeric(30, 6)= 0;
    DECLARE _er decimal_strict2 = 0;
BEGIN

    SELECT SUM(amount_in_local_currency)
    INTO _debit
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(_account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids($1))
    AND tran_type='Dr';

    SELECT SUM(amount_in_local_currency)
    INTO _credit
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(_account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids($1))
    AND tran_type='Cr';

    _er := COALESCE(finance.convert_exchange_rate($1, _local_currency_code, _base_currency_code), 0);


    IF(_er = 0) THEN
        RAISE INFO 'Exchange rate between % and % was not found.', _local_currency_code, _base_currency_code
        USING ERRCODE='P4010';
    END IF;


    _amount_in_local_currency = COALESCE(_debit, 0) - COALESCE(_credit, 0);


    _amount_in_base_currency = _amount_in_local_currency * _er; 

    RETURN _amount_in_base_currency;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.get_total_supplier_due.sql --<--<--
DROP FUNCTION IF EXISTS inventory.get_total_supplier_due(office_id integer, supplier_id integer);

CREATE FUNCTION inventory.get_total_supplier_due(office_id integer, supplier_id integer)
RETURNS DECIMAL(24, 4)
AS
$$
    DECLARE _account_id                     integer         = inventory.get_account_id_by_supplier_id($2);
    DECLARE _debit                          numeric(30, 6)  = 0;
    DECLARE _credit                         numeric(30, 6)  = 0;
    DECLARE _local_currency_code            national character varying(12) = core.get_currency_code_by_office_id($1); 
    DECLARE _base_currency_code             national character varying(12) = inventory.get_currency_code_by_customer_id($2);
    DECLARE _amount_in_local_currency       numeric(30, 6)= 0;
    DECLARE _amount_in_base_currency        numeric(30, 6)= 0;
    DECLARE _er decimal_strict2 = 0;
BEGIN

    SELECT SUM(amount_in_local_currency)
    INTO _debit
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(_account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids($1))
    AND tran_type='Dr';

    SELECT SUM(amount_in_local_currency)
    INTO _credit
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(_account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids($1))
    AND tran_type='Cr';

    _er := COALESCE(finance.convert_exchange_rate($1, _local_currency_code, _base_currency_code), 0);


    IF(_er = 0) THEN
        RAISE INFO 'Exchange rate between % and % was not found.', _local_currency_code, _base_currency_code
        USING ERRCODE='P4010';
    END IF;


    _amount_in_local_currency = COALESCE(_credit, 0) - COALESCE(_debit, 0);


    _amount_in_base_currency = _amount_in_local_currency * _er; 

    RETURN _amount_in_base_currency;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/02.functions-and-logic/inventory.post_transfer.sql --<--<--
/*
TODO: 
	Change this function as implemented in SQL Server.
	The change includes user friendly error message 
	indicating which inventory item 
	is not present in the store.
*/

DROP FUNCTION IF EXISTS inventory.post_transfer
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _value_date                             date,
    _book_date                              date,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _details                                inventory.transfer_type[]
);


CREATE FUNCTION inventory.post_transfer
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _value_date                             date,
    _book_date                              date,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _details                                inventory.transfer_type[]
)
RETURNS bigint
AS
$$
    DECLARE _transaction_master_id          bigint;
    DECLARE _checkout_id                    bigint;
    DECLARE _book_name                      text='Inventory Transfer';

	DECLARE _taxable_total					numeric(30, 6);
    DECLARE _tax_total                      public.money_strict2;
	DECLARE _nontaxable_total				numeric(30, 6);
    DECLARE _tax_account_id                 integer;
BEGIN
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book_name, _value_date) THEN
        RETURN 0;
    END IF;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_stock_details
    (
        tran_type       national character varying(2),
        store_id        integer,
        store_name      national character varying(500),
        item_id         integer,
        item_code       national character varying(24),
        unit_id         integer,
        base_unit_id    integer,
        unit_name       national character varying(500),
        quantity        public.decimal_strict,
        base_quantity   public.decimal_strict,                
        price           money_strict
    )
    ON COMMIT DROP;

    INSERT INTO temp_stock_details(tran_type, store_name, item_code, unit_name, quantity, price)
    SELECT tran_type, store_name, item_code, unit_name, quantity, rate * quantity
    FROM explode_array(_details);

    IF EXISTS
    (
        SELECT 1 FROM temp_stock_details
        GROUP BY item_code, store_name
        HAVING COUNT(item_code) <> 1
    ) THEN
        RAISE EXCEPTION 'An item can appear only once in a store.'
        USING ERRCODE='P5202';
    END IF;

    UPDATE temp_stock_details SET 
    item_id         = inventory.get_item_id_by_item_code(item_code),
    unit_id         = inventory.get_unit_id_by_unit_name(unit_name),
    store_id        = inventory.get_store_id_by_store_name(store_name);

    IF EXISTS
    (
        SELECT * FROM temp_stock_details
        WHERE item_id IS NULL OR unit_id IS NULL OR store_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Invalid data supplied.'
        USING ERRCODE='P3000';
    END IF;

    UPDATE temp_stock_details 
    SET
        base_unit_id    = inventory.get_root_unit_id(unit_id),
        base_quantity   = inventory.get_base_quantity_by_unit_id(unit_id, quantity);

    UPDATE temp_stock_details 
    SET
        price           = inventory.get_item_cost_price(item_id, unit_id)
    WHERE temp_stock_details.price IS NULL;

    IF EXISTS
    (
        SELECT item_code FROM temp_stock_details
        GROUP BY item_code
        HAVING SUM(CASE WHEN tran_type='Dr' THEN base_quantity ELSE base_quantity *-1 END) <> 0
    ) THEN
        RAISE EXCEPTION 'Referencing sides are not equal.'
        USING ERRCODE='P5000';        
    END IF;


    IF EXISTS
    (
            SELECT 1
            FROM 
            inventory.stores
            WHERE inventory.stores.store_id
            IN
            (
                SELECT temp_stock_details.store_id
                FROM temp_stock_details
            )
            HAVING COUNT(DISTINCT inventory.stores.office_id) > 1

    ) THEN
        RAISE EXCEPTION E'Access is denied!\nA stock journal transaction cannot references multiple branches.'
        USING ERRCODE='P9013';
    END IF;

    IF EXISTS
    (
            SELECT 1
            FROM 
            temp_stock_details
            WHERE tran_type = 'Cr'
            AND quantity > inventory.count_item_in_stock(item_id, unit_id, store_id)
    ) THEN
        RAISE EXCEPTION 'Negative stock is not allowed.'
        USING ERRCODE='P5001';
    END IF;


    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, reference_number, statement_reference)
    SELECT
            nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
            finance.get_new_transaction_counter(_value_date), 
            finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
            _book_name,
            _value_date,
            _book_date,
            _login_id,
            _user_id,
            _office_id,
            _reference_number,
            _statement_reference;


    _transaction_master_id  := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));


    INSERT INTO inventory.checkouts(checkout_id, transaction_master_id, transaction_book, value_date, book_date, posted_by, office_id, taxable_total, discount, tax_rate, tax, nontaxable_total)
    SELECT nextval(pg_get_serial_sequence('inventory.checkouts', 'checkout_id')), _transaction_master_id, _book_name, _value_date, _book_date, _user_id, _office_id
    , 1, 0, 0, 0, 0; --> Could not understand this one.

    _checkout_id  := currval(pg_get_serial_sequence('inventory.checkouts', 'checkout_id'));

    INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price)
    SELECT _checkout_id, _value_date, _book_date, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price
    FROM temp_stock_details;
    
    
    PERFORM finance.auto_verify(_transaction_master_id, _office_id);
    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;


-- SELECT * FROM inventory.post_transfer(1, 1, 1, '1-1-2020', '1-1-2020', '22', 'Test', 
-- ARRAY[
-- ROW('Cr', 'Store 1', 'RMBP', 'Dozen', 2)::inventory.transfer_type,
-- ROW('Dr', 'Godown 1', 'RMBP', 'Piece', 24)::inventory.transfer_type
-- ]
-- );




-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/03.menus/menus.sql --<--<--
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventorySetup', 'Inventory Setup', '/dashboard/inventory/setup/is', 'content', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'TransactionDetails', 'Transaction Details', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/TransactionDetails.xml', 'content', 'Setup');


SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Inventory',
    '{*}'::text[]
);



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/05.scrud-views/inventory.compound_unit_scrud_view.sql --<--<--
DROP VIEW IF EXISTS inventory.compound_unit_scrud_view;

CREATE VIEW inventory.compound_unit_scrud_view
AS
SELECT
    compound_unit_id,
    base_unit.unit_name base_unit_name,
    value,
    compare_unit.unit_name compare_unit_name
FROM
    inventory.compound_units,
    inventory.units base_unit,
    inventory.units compare_unit
WHERE inventory.compound_units.base_unit_id = base_unit.unit_id
AND inventory.compound_units.compare_unit_id = compare_unit.unit_id;


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/05.scrud-views/inventory.customer_scrud_view.sql --<--<--
DROP VIEW IF EXISTS inventory.customer_scrud_view;

CREATE VIEW inventory.customer_scrud_view
AS
SELECT
    inventory.customers.customer_id,
    inventory.customers.customer_code,
    inventory.customers.customer_name,
    inventory.customer_types.customer_type_code || ' (' || inventory.customer_types.customer_type_name || ')' AS customer_type,
    inventory.customers.currency_code,
    inventory.customers.company_name,
    inventory.customers.company_phone_numbers,
    inventory.customers.contact_first_name,
    inventory.customers.contact_middle_name,
    inventory.customers.contact_last_name,
    inventory.customers.contact_phone_numbers,
    inventory.customers.photo
FROM inventory.customers
INNER JOIN inventory.customer_types
ON inventory.customer_types.customer_type_id = inventory.customers.customer_type_id;


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/05.scrud-views/inventory.item_scrud_view.sql --<--<--
DROP VIEW IF EXISTS inventory.item_scrud_view;

CREATE VIEW inventory.item_scrud_view
AS
SELECT
    inventory.items.item_id,
    inventory.items.item_code,
    inventory.items.item_name,
    inventory.items.barcode,
    inventory.items.item_group_id,
    inventory.item_groups.item_group_name,
    inventory.item_types.item_type_id,
    inventory.item_types.item_type_name,
    inventory.items.brand_id,
    inventory.brands.brand_name,
    inventory.suppliers.supplier_name,
    inventory.items.unit_id,
    inventory.units.unit_code,
    inventory.units.unit_name,
    inventory.items.hot_item,
    inventory.items.cost_price,
    inventory.items.selling_price,
    inventory.items.maintain_inventory,
    inventory.items.allow_sales,
    inventory.items.allow_purchase,
    inventory.items.photo
FROM inventory.items
LEFT JOIN inventory.item_groups
ON inventory.item_groups.item_group_id = inventory.items.item_group_id
LEFT JOIN inventory.item_types
ON inventory.item_types.item_type_id = inventory.items.item_type_id
LEFT JOIN inventory.brands
ON inventory.brands.brand_id = inventory.items.brand_id
LEFT JOIN inventory.units
ON inventory.units.unit_id = inventory.items.unit_id
LEFT JOIN inventory.suppliers
ON inventory.suppliers.supplier_id = inventory.items.preferred_supplier_id
WHERE NOT inventory.items.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/PostgreSQL/2.1.update/src/99.ownership.sql --<--<--
DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.schemaname || '.' || this.tablename ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.mat_view ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
    DECLARE _version_number integer = current_setting('server_version_num')::integer;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    IF(_version_number < 110000) THEN
        FOR this IN 
        SELECT 'ALTER '
            || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    ELSE
        FOR this IN 
        SELECT 'ALTER '
            || CASE p.prokind WHEN 'a' THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    END IF;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER VIEW '|| this.schemaname || '.' || this.viewname ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO frapid_db_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT      'ALTER TYPE ' || n.nspname || '.' || t.typname || ' OWNER TO frapid_db_user;' AS sql
    FROM        pg_type t 
    LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
    WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
    AND         NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND         typtype NOT IN ('b')
    AND         n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.schemaname || '.' || this.tablename ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.mat_view  ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
    DECLARE _version_number integer = current_setting('server_version_num')::integer;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    IF(_version_number < 110000) THEN
        FOR this IN 
        SELECT 'GRANT EXECUTE ON '
            || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    ELSE
        FOR this IN 
        SELECT 'GRANT EXECUTE ON '
            || CASE p.prokind WHEN 'a' THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    END IF;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON '|| this.schemaname || '.' || this.viewname ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT USAGE ON SCHEMA ' || nspname || ' TO report_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


