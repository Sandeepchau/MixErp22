-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
DROP SCHEMA IF EXISTS sales CASCADE;

CREATE SCHEMA sales;

CREATE TABLE sales.gift_cards
(
    gift_card_id                            SERIAL PRIMARY KEY,
    gift_card_number                        national character varying(100) NOT NULL,
	payable_account_id					    integer NOT NULL REFERENCES finance.accounts,
    customer_id                             integer REFERENCES inventory.customers,
    first_name                              national character varying(100),
    middle_name                             national character varying(100),
    last_name                               national character varying(100),
    address_line_1                          national character varying(128),   
    address_line_2                          national character varying(128),
    street                                  national character varying(100),
    city                                    national character varying(100),
    state                                   national character varying(100),
    country                                 national character varying(100),
    po_box                                  national character varying(100),
    zip_code                                national character varying(100),
    phone_numbers                           national character varying(100),
    fax                                     national character varying(100),    
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX gift_cards_gift_card_number_uix
ON sales.gift_cards(UPPER(gift_card_number))
WHERE NOT deleted;

--TODO: Create a trigger to disable deleting a gift card if the balance is not zero.

CREATE TABLE sales.gift_card_transactions
(
    transaction_id                          BIGSERIAL PRIMARY KEY,
	gift_card_id							integer NOT NULL REFERENCES sales.gift_cards,
	value_date								date,
	book_date								date,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    transaction_type                        national character varying(2) NOT NULL
                                            CHECK(transaction_type IN('Dr', 'Cr')),
    amount                                  public.money_strict
);

CREATE TABLE sales.late_fee
(
    late_fee_id                             SERIAL PRIMARY KEY,
    late_fee_code                           national character varying(24) NOT NULL,
    late_fee_name                           national character varying(500) NOT NULL,
    is_flat_amount                          boolean NOT NULL DEFAULT(false),
    rate                                    numeric(30, 6) NOT NULL,
	account_id 								integer NOT NULL REFERENCES finance.accounts,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.late_fee_postings
(
	transaction_master_id               	bigint PRIMARY KEY REFERENCES finance.transaction_master,
	customer_id                         	integer NOT NULL REFERENCES inventory.customers,
	value_date                          	date NOT NULL,
	late_fee_tran_id                    	bigint NOT NULL REFERENCES finance.transaction_master,
	amount                              	public.money_strict
);

CREATE TABLE sales.price_types
(
    price_type_id                           SERIAL PRIMARY KEY,
    price_type_code                         national character varying(24) NOT NULL,
    price_type_name                         national character varying(500) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.item_selling_prices
(
    item_selling_price_id                   BIGSERIAL PRIMARY KEY,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    customer_type_id                        integer REFERENCES inventory.customer_types,
    price_type_id                           integer REFERENCES sales.price_types,
    includes_tax                            boolean NOT NULL DEFAULT(false),
    price                                   public.money_strict NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.customerwise_selling_prices
(
	selling_price_id						BIGSERIAL PRIMARY KEY,
	item_id									integer NOT NULL REFERENCES inventory.items,
	customer_id								integer NOT NULL REFERENCES inventory.customers,
	unit_id									integer NOT NULL REFERENCES inventory.units,
	price									numeric(30, 6),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE TABLE sales.payment_terms
(
    payment_term_id                         SERIAL PRIMARY KEY,
    payment_term_code                       national character varying(24) NOT NULL,
    payment_term_name                       national character varying(500) NOT NULL,
    due_on_date                             boolean NOT NULL DEFAULT(false),
    due_days                                public.integer_strict2 NOT NULL DEFAULT(0),
    due_frequency_id                        integer REFERENCES finance.frequencies,
    grace_period                            integer NOT NULL DEFAULT(0),
    late_fee_id                             integer REFERENCES sales.late_fee,
    late_fee_posting_frequency_id           integer REFERENCES finance.frequencies,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX payment_terms_payment_term_code_uix
ON sales.payment_terms(UPPER(payment_term_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX payment_terms_payment_term_name_uix
ON sales.payment_terms(UPPER(payment_term_name))
WHERE NOT deleted;

CREATE TABLE sales.cashiers
(
    cashier_id                              SERIAL PRIMARY KEY,
    cashier_code                            national character varying(12) NOT NULL,
    pin_code                                national character varying(8) NOT NULL,
    associated_user_id                      integer NOT NULL REFERENCES account.users,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    valid_from                              date NOT NULL,
    valid_till                              date NOT NULL CHECK(valid_till >= valid_from),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX cashiers_cashier_code_uix
ON sales.cashiers(UPPER(cashier_code))
WHERE NOT deleted;

CREATE TABLE sales.cashier_login_info
(
    cashier_login_info_id                   uuid PRIMARY KEY DEFAULT(gen_random_uuid()),
    counter_id                              integer REFERENCES inventory.counters,
    cashier_id                              integer REFERENCES sales.cashiers,
    login_date                              TIMESTAMP WITH TIME ZONE NOT NULL,
    success                                 boolean NOT NULL,
    attempted_by                            integer NOT NULL REFERENCES account.users,
    browser                                 text,
    ip_address                              text,
    user_agent                              text,    
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);



CREATE TABLE sales.quotations
(
    quotation_id                            BIGSERIAL PRIMARY KEY,
    value_date                              date NOT NULL,
	expected_delivery_date					date NOT NULL,
    transaction_timestamp                   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
    customer_id                             integer NOT NULL REFERENCES inventory.customers,
    price_type_id                           integer NOT NULL REFERENCES sales.price_types,
	shipper_id								integer REFERENCES inventory.shippers,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    reference_number                        national character varying(24),
	terms									national character varying(500),
    internal_memo                           national character varying(500),
	taxable_total 							numeric(30, 6) NOT NULL DEFAULT(0),
	discount 								numeric(30, 6) NOT NULL DEFAULT(0),
	tax_rate 								numeric(30, 6) NOT NULL DEFAULT(0),
	tax 									numeric(30, 6) NOT NULL DEFAULT(0),
	nontaxable_total 						numeric(30, 6) NOT NULL DEFAULT(0),
	cancelled								boolean NOT NULL DEFAULT(false),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.quotation_details
(
    quotation_detail_id                     BIGSERIAL PRIMARY KEY,
    quotation_id                            bigint NOT NULL REFERENCES sales.quotations,
    value_date                              date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    price                                   public.money_strict NOT NULL,
	discount_rate							numeric(30, 6) NOT NULL,
    discount                           		public.decimal_strict2 NOT NULL DEFAULT(0),    
    shipping_charge                         public.money_strict2 NOT NULL DEFAULT(0),    
	is_taxed 								boolean NOT NULL,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    quantity                                public.decimal_strict2 NOT NULL
);


CREATE TABLE sales.orders
(
    order_id                                BIGSERIAL PRIMARY KEY,
    quotation_id                            bigint REFERENCES sales.quotations,
    value_date                              date NOT NULL,
	expected_delivery_date					date NOT NULL,
    transaction_timestamp                   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
    customer_id                             integer NOT NULL REFERENCES inventory.customers,
    price_type_id                           integer NOT NULL REFERENCES sales.price_types,
	shipper_id								integer REFERENCES inventory.shippers,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    reference_number                        national character varying(24),
    terms                                   national character varying(500),
    internal_memo                           national character varying(500),
	taxable_total 							numeric(30, 6) NOT NULL DEFAULT(0),
	discount 								numeric(30, 6) NOT NULL DEFAULT(0),
	tax_rate 								numeric(30, 6) NOT NULL DEFAULT(0),
	tax 									numeric(30, 6) NOT NULL DEFAULT(0),
	nontaxable_total 						numeric(30, 6) NOT NULL DEFAULT(0),
	cancelled								boolean NOT NULL DEFAULT(false),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.order_details
(
    order_detail_id                         BIGSERIAL PRIMARY KEY,
    order_id                                bigint NOT NULL REFERENCES sales.orders,
    value_date                              date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    price                                   public.money_strict NOT NULL,
	discount_rate							numeric(30, 6) NOT NULL,
    discount                           		public.decimal_strict2 NOT NULL DEFAULT(0),    
    shipping_charge                         public.money_strict2 NOT NULL DEFAULT(0),    
	is_taxed 								boolean NOT NULL,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    quantity                                public.decimal_strict2 NOT NULL
);


CREATE TABLE sales.coupons
(
    coupon_id                                   SERIAL PRIMARY KEY,
    coupon_name                                 national character varying(100) NOT NULL,
    coupon_code                                 national character varying(100) NOT NULL,
    discount_rate                               public.decimal_strict NOT NULL,
    is_percentage                               boolean NOT NULL DEFAULT(false),
    maximum_discount_amount                     public.decimal_strict,
    associated_price_type_id                    integer REFERENCES sales.price_types,
    minimum_purchase_amount                     public.decimal_strict2,
    maximum_purchase_amount                     public.decimal_strict2,
    begins_from                                 date,
    expires_on                                  date,
    maximum_usage                               public.integer_strict,
    enable_ticket_printing                      boolean,
    for_ticket_of_price_type_id                 integer REFERENCES sales.price_types,
    for_ticket_having_minimum_amount            public.decimal_strict2,
    for_ticket_having_maximum_amount            public.decimal_strict2,
    for_ticket_of_unknown_customers_only        boolean,
    audit_user_id                               integer REFERENCES account.users,
    audit_ts                                    TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									    boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX coupons_coupon_code_uix
ON sales.coupons(UPPER(coupon_code));



CREATE TABLE sales.sales
(
    sales_id                                BIGSERIAL PRIMARY KEY,
	invoice_number							bigint NOT NULL,
	fiscal_year_code						national character varying(12) NOT NULL REFERENCES finance.fiscal_year,
	cash_repository_id						integer REFERENCES finance.cash_repositories,
	price_type_id							integer NOT NULL REFERENCES sales.price_types,
	sales_order_id							bigint REFERENCES sales.orders,
	sales_quotation_id					    bigint REFERENCES sales.quotations,
	transaction_master_id					bigint NOT NULL REFERENCES finance.transaction_master,
	receipt_transaction_master_id			bigint REFERENCES finance.transaction_master,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers,
	salesperson_id							integer REFERENCES account.users,
	total_amount							public.money_strict NOT NULL,
	coupon_id								integer REFERENCES sales.coupons,
	is_flat_discount						boolean,
	discount								public.decimal_strict2,
	total_discount_amount					public.decimal_strict2,	
    is_credit                               boolean NOT NULL DEFAULT(false),
	credit_settled							boolean,
    payment_term_id                         integer REFERENCES sales.payment_terms,
    tender                                  numeric(30, 6) NOT NULL,
    change                                  numeric(30, 6) NOT NULL,
    gift_card_id                            integer REFERENCES sales.gift_cards,
    check_number                            national character varying(100),
    check_date                              date,
    check_bank_name                         national character varying(1000),
    check_amount                            public.money_strict2,
	reward_points							numeric(30, 6) NOT NULL DEFAULT(0)
);

CREATE UNIQUE INDEX sales_invoice_number_fiscal_year_uix
ON sales.sales(UPPER(fiscal_year_code), invoice_number);


CREATE TABLE sales.customer_receipts
(
    receipt_id                              BIGSERIAL PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    customer_id                             integer NOT NULL REFERENCES inventory.customers,
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    er_debit                                decimal_strict NOT NULL,
    er_credit                               decimal_strict NOT NULL,
    cash_repository_id                      integer NULL REFERENCES finance.cash_repositories,
    posted_date                             date NULL,
    tender                                  public.money_strict2,
    change                                  public.money_strict2,
    amount                                  public.money_strict2,
    collected_on_bank_id					integer REFERENCES finance.bank_accounts,
	collected_bank_instrument_code			national character varying(500),
	collected_bank_transaction_code			national character varying(500),
	check_number                            national character varying(100),
    check_date                              date,
    check_bank_name                         national character varying(1000),
    check_amount                            public.money_strict2,
    check_cleared                           boolean,    
    check_clear_date                        date,   
    check_clearing_memo                     national character varying(1000),
    check_clearing_transaction_master_id    bigint REFERENCES finance.transaction_master,
    gift_card_number                        national character varying(100)
);

CREATE INDEX customer_receipts_transaction_master_id_inx
ON sales.customer_receipts(transaction_master_id);

CREATE INDEX customer_receipts_customer_id_inx
ON sales.customer_receipts(customer_id);

CREATE INDEX customer_receipts_currency_code_inx
ON sales.customer_receipts(currency_code);

CREATE INDEX customer_receipts_cash_repository_id_inx
ON sales.customer_receipts(cash_repository_id);

CREATE INDEX customer_receipts_posted_date_inx
ON sales.customer_receipts(posted_date);



CREATE TABLE sales.returns
(
    return_id                               BIGSERIAL PRIMARY KEY,
    sales_id                                bigint NOT NULL REFERENCES sales.sales,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
	transaction_master_id					bigint NOT NULL REFERENCES finance.transaction_master,
	return_transaction_master_id			bigint NOT NULL REFERENCES finance.transaction_master,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers,
	price_type_id							integer NOT NULL REFERENCES sales.price_types,
	is_credit								boolean
);


CREATE TABLE sales.opening_cash
(
	opening_cash_id						    BIGSERIAL PRIMARY KEY,
	user_id									integer NOT NULL REFERENCES account.users,
	transaction_date						date NOT NULL,
	amount									numeric(30, 6) NOT NULL,
	provided_by								national character varying(1000) NOT NULL DEFAULT(''),
	memo									national character varying(4000) DEFAULT(''),
	closed									boolean NOT NULL DEFAULT(false),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX opening_cash_transaction_date_user_id_uix
ON sales.opening_cash(user_id, transaction_date);

CREATE TABLE sales.closing_cash
(
	closing_cash_id							BIGSERIAL PRIMARY KEY,
	user_id									integer NOT NULL REFERENCES account.users,
	transaction_date						date NOT NULL,
	opening_cash							numeric(30, 6) NOT NULL,
	total_cash_sales						numeric(30, 6) NOT NULL,
	submitted_to							national character varying(1000) NOT NULL DEFAULT(''),
	memo									national character varying(4000) NOT NULL DEFAULT(''),
	deno_1000								integer DEFAULT(0),
	deno_500								integer DEFAULT(0),
	deno_250								integer DEFAULT(0),
	deno_200								integer DEFAULT(0),
	deno_100								integer DEFAULT(0),
	deno_50									integer DEFAULT(0),
	deno_25									integer DEFAULT(0),
	deno_20									integer DEFAULT(0),
	deno_10									integer DEFAULT(0),
	deno_5									integer DEFAULT(0),
	deno_2									integer DEFAULT(0),
	deno_1									integer DEFAULT(0),
	coins									numeric(30, 6) DEFAULT(0),
	submitted_cash							numeric(30, 6) NOT NULL,
	approved_by								integer REFERENCES account.users,
	approval_memo							national character varying(4000),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX closing_cash_transaction_date_user_id_uix
ON sales.closing_cash(user_id, transaction_date);


CREATE TYPE sales.sales_detail_type
AS
(
    store_id            integer,
	transaction_type	national character varying(2),
    item_id           	integer,
    quantity            public.decimal_strict,
    unit_id           	integer,
    price               public.money_strict,
    discount_rate       public.decimal_strict2,
    discount       		public.money_strict2,
    shipping_charge     public.money_strict2,
	is_taxed			boolean
);




-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.add_gift_card_fund.sql --<--<--
DROP FUNCTION IF EXISTS sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
);

CREATE FUNCTION sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
)
RETURNS bigint
AS
$$
    DECLARE _transaction_master_id              bigint;
    DECLARE _book_name                          national character varying(50) = 'Gift Card Fund Sales';
    DECLARE _payable_account_id                 integer;
    DECLARE _currency_code                      national character varying(12);
BEGIN
    _currency_code                              := core.get_currency_code_by_office_id(_office_id);
    _payable_account_id                         := sales.get_payable_account_id_by_gift_card_id(_gift_card_id);
    _transaction_master_id                      := nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, cost_center_id, reference_number, statement_reference)
    SELECT
        _transaction_master_id,
        finance.get_new_transaction_counter(_value_date),
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book_name,
        _value_date,
        _book_date,
        _login_id,
        _user_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Cr', 
        _payable_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Dr', 
        _debit_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO sales.gift_card_transactions(gift_card_id, value_date, book_date, transaction_master_id, transaction_type, amount)
    SELECT _gift_card_id, _value_date, _book_date, _transaction_master_id, 'Cr', _amount;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.add_gift_card_fund(1, 1, 1, sales.get_gift_card_id_by_gift_card_number('123456'), '1-1-2020', '1-1-2020', 1, 2000, 1, '', '');



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.add_opening_cash.sql --<--<--
DROP FUNCTION IF EXISTS sales.add_opening_cash
(
	_user_id								integer,
	_transaction_date						TIMESTAMP,
	_amount									numeric(30, 6),
	_provided_by							national character varying(1000),
	_memo									national character varying(4000)
);

CREATE FUNCTION sales.add_opening_cash
(
	_user_id								integer,
	_transaction_date						TIMESTAMP,
	_amount									numeric(30, 6),
	_provided_by							national character varying(1000),
	_memo									national character varying(4000)
)
RETURNS void
AS
$$
BEGIN
	IF NOT EXISTS
	(
		SELECT 1
		FROM sales.opening_cash
		WHERE user_id = _user_id
		AND transaction_date = _transaction_date
	) THEN
		INSERT INTO sales.opening_cash(user_id, transaction_date, amount, provided_by, memo, audit_user_id, audit_ts, deleted)
		SELECT _user_id, _transaction_date, _amount, _provided_by, _memo, _user_id, NOW(), false;
	ELSE
		UPDATE sales.opening_cash
		SET
			amount = _amount,
			provided_by = _provided_by,
			memo = _memo,
			user_id = _user_id,
			audit_user_id = _user_id,
			audit_ts = NOW(),
			deleted = false
		WHERE user_id = _user_id
		AND transaction_date = _transaction_date;
	END IF;
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_active_coupon_id_by_coupon_code.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100));

CREATE FUNCTION sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.coupons.coupon_id
    FROM sales.coupons
    WHERE sales.coupons.coupon_code = _coupon_code
    AND COALESCE(sales.coupons.begins_from, NOW()::date) >= NOW()::date
    AND COALESCE(sales.coupons.expires_on, NOW()::date) <= NOW()::date
    AND NOT sales.coupons.deleted;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_avaiable_coupons_to_print.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_avaiable_coupons_to_print(_tran_id bigint);

CREATE FUNCTION sales.get_avaiable_coupons_to_print(_tran_id bigint)
RETURNS TABLE
(
    coupon_id               integer
)
AS
$$
    DECLARE _price_type_id                  integer;
    DECLARE _total_amount                   public.money_strict;
    DECLARE _customer_id                    integer;
BEGIN
    DROP TABLE IF EXISTS temp_coupons;
    CREATE TEMPORARY TABLE temp_coupons
    (
        coupon_id                           integer,
        maximum_usage                       public.integer_strict,
        total_used                          integer
    ) ON COMMIT DROP;
    
    SELECT
        sales.sales.price_type_id,
        sales.sales.total_amount,
        sales.sales.customer_id
    INTO
        _price_type_id,
        _total_amount,
        _customer_id
    FROM sales.sales
    WHERE sales.sales.transaction_master_id = _tran_id;


    INSERT INTO temp_coupons
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE NOT sales.coupons.deleted
    AND sales.coupons.enable_ticket_printing = true
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= NOW()::date)
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= NOW()::date)
    AND sales.coupons.for_ticket_of_price_type_id IS NULL
    AND COALESCE(sales.coupons.for_ticket_having_minimum_amount, 0) = 0
    AND COALESCE(sales.coupons.for_ticket_having_maximum_amount, 0) = 0
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    INSERT INTO temp_coupons
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE NOT sales.coupons.deleted
    AND sales.coupons.enable_ticket_printing = true
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= NOW()::date)
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= NOW()::date)
    AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = _price_type_id)
    AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= _total_amount)
    AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= _total_amount)
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    IF(COALESCE(_customer_id, 0) > 0) THEN
        INSERT INTO temp_coupons
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE NOT sales.coupons.deleted
        AND sales.coupons.enable_ticket_printing = true
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= NOW()::date)
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= NOW()::date)
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = _price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= _total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= _total_amount)
        AND NOT sales.coupons.for_ticket_of_unknown_customers_only;
    ELSE
        INSERT INTO temp_coupons
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE NOT sales.coupons.deleted
        AND sales.coupons.enable_ticket_printing = true
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= NOW()::date)
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= NOW()::date)
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = _price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= _total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= _total_amount)
        AND sales.coupons.for_ticket_of_unknown_customers_only;    
    END IF;

    UPDATE temp_coupons
    SET total_used = 
    (
        SELECT COUNT(*)
        FROM sales.sales
        WHERE sales.sales.coupon_id = temp_coupons.coupon_id 
    );

    DELETE FROM temp_coupons WHERE total_used > maximum_usage;
    
    RETURN QUERY
    SELECT temp_coupons.coupon_id FROM temp_coupons;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.get_avaiable_coupons_to_print(2);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_customer_account_detail.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_customer_account_detail(integer, date, date, integer);
CREATE OR REPLACE FUNCTION sales.get_customer_account_detail
(
    _customer_id        integer,
    _from               date,
    _to                 date,
    _office_id          integer
)
RETURNS TABLE
(
    id                      integer, 
    value_date              date, 
    book_date               date,
    tran_id                 bigint,
    tran_code               text,
    invoice_number          bigint, 
    tran_type               text, 
    debit                   numeric(30, 6), 
    credit                  numeric(30, 6), 
    balance                 numeric(30, 6)
)
AS
$BODY$
BEGIN
    CREATE TEMPORARY TABLE _customer_account_detail
    (
        id                      SERIAL NOT NULL,
        value_date              date,
        book_date               date,
        tran_id                 bigint,
        tran_code               text,
        invoice_number          bigint,
        tran_type               text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _customer_account_detail
    (
        value_date, 
        book_date,
        tran_id,
        tran_code,
        invoice_number, 
        tran_type, 
        debit, 
        credit
    )
    SELECT 
        customer_transaction_view.value_date,
        customer_transaction_view.book_date,
        customer_transaction_view.transaction_master_id,
        customer_transaction_view.transaction_code,
        customer_transaction_view.invoice_number,
        customer_transaction_view.statement_reference,
        customer_transaction_view.debit,
        customer_transaction_view.credit
    FROM sales.customer_transaction_view
    LEFT JOIN inventory.customers
    ON customer_transaction_view.customer_id = customers.customer_id
    LEFT JOIN sales.sales_view
    ON sales_view.invoice_number = customer_transaction_view.invoice_number
    WHERE customer_transaction_view.customer_id = _customer_id
    AND NOT customers.deleted
	AND sales_view.office_id = _office_id
    AND customer_transaction_view.value_date BETWEEN _from AND _to;

    UPDATE _customer_account_detail 
    SET balance = c.balance
    FROM
    (
        SELECT p.id,
            SUM(COALESCE(c.debit, 0) - COALESCE(c.credit, 0)) As balance
        FROM _customer_account_detail p
        LEFT JOIN _customer_account_detail c
        ON c.id <= p.id
        GROUP BY p.id
        ORDER BY p.id
    ) AS c
    WHERE _customer_account_detail.id = c.id;

    RETURN QUERY
    SELECT * FROM _customer_account_detail;
END
$BODY$
 LANGUAGE plpgsql;


--select * from sales.get_customer_account_detail(1, '1-1-2000', '1-1-2060', 1);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_gift_card_balance.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_gift_card_balance(_gift_card_id integer, _value_date date);

CREATE FUNCTION sales.get_gift_card_balance(_gift_card_id integer, _value_date date)
RETURNS numeric(30, 6)
AS
$$
    DECLARE _debit          numeric(30, 6);
    DECLARE _credit         numeric(30, 6);
BEGIN
    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _debit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Dr'
    AND finance.transaction_master.value_date <= _value_date;

    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _credit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Cr'
    AND finance.transaction_master.value_date <= _value_date;

    --Gift cards are account payables
    RETURN COALESCE(_credit, 0) - COALESCE(_debit, 0);
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_gift_card_detail.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_gift_card_detail(national character varying(50), date, date, integer);
CREATE FUNCTION sales.get_gift_card_detail
(
    _card_number        national character varying(50),
    _from               date,
    _to                 date,
    _office_id          integer
)
RETURNS TABLE
(
    id                  integer, 
    gift_card_id        integer, 
    transaction_ts      timestamp without time zone, 
    statement_reference text, 
    debit               numeric(30,6), 
    credit              numeric(30,6), 
    balance             numeric(30,6)
)
AS
$BODY$
BEGIN
    CREATE TEMPORARY TABLE  _gift_card_detail
    (
        id                      SERIAL NOT NULL,    
        gift_card_id            integer,
        transaction_ts          timestamp without time zone, 
        statement_reference     text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _gift_card_detail
    (
        gift_card_id, 
        transaction_ts, 
        statement_reference, 
        debit, 
        credit
    )
    SELECT 
        t.gift_card_id, 
        t.transaction_ts, 
        t.statement_reference, 
        t.debit, 
        t.credit
    FROM
    (
        SELECT  gift_card_transactions.gift_card_id,
                transaction_master.transaction_ts,
                transaction_master.statement_reference,
                CASE WHEN gift_card_transactions.transaction_type = 'Dr' THEN gift_card_transactions.amount END AS debit,
                CASE WHEN gift_card_transactions.transaction_type = 'Cr' THEN gift_card_transactions.amount END AS credit
        FROM sales.gift_card_transactions
        JOIN finance.transaction_master
            ON transaction_master.transaction_master_id = gift_card_transactions.transaction_master_id
        JOIN sales.gift_cards
            ON gift_cards.gift_card_id = gift_card_transactions.gift_card_id
        WHERE gift_cards.gift_card_number = _card_number
        AND transaction_master.verification_status_id > 0
        AND NOT transaction_master.deleted
		AND transaction_master.office_id IN (SELECT get_office_ids FROM core.get_office_ids(_office_id))
        AND transaction_master.transaction_ts::date BETWEEN _from AND _to
        UNION ALL
        
        SELECT 
            sales.gift_card_id,
            transaction_master.transaction_ts,
            transaction_master.statement_reference,
            sales.total_amount,
            0
            FROM sales.sales
            LEFT JOIN finance.transaction_master
            ON transaction_master.transaction_master_id = sales.transaction_master_id
            JOIN sales.gift_cards
            ON gift_cards.gift_card_id = sales.gift_card_id
            WHERE sales.gift_card_id IS NOT NULL
            AND gift_cards.gift_card_number = _card_number
            AND transaction_master.verification_status_id > 0
            AND NOT transaction_master.deleted
            AND transaction_master.office_id IN (SELECT get_office_ids FROM core.get_office_ids(_office_id))
            AND transaction_master.transaction_ts::date BETWEEN _from AND _to
        ) t
        ORDER BY t.transaction_ts ASC;

    UPDATE _gift_card_detail
    SET balance = c.balance
    FROM
    (
        SELECT
            p.id, 
            SUM(COALESCE(c.credit, 0) - COALESCE(c.debit, 0)) As balance
        FROM _gift_card_detail p
        LEFT JOIN _gift_card_detail AS c 
            ON (c.transaction_ts <= p.transaction_ts)
        GROUP BY p.id
        ORDER BY p.id    
     ) AS c
    WHERE _gift_card_detail.id = c.id;
    
    RETURN QUERY
    (
        SELECT * FROM _gift_card_detail
        ORDER BY transaction_ts ASC
    );
END
$BODY$
  LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_gift_card_id_by_gift_card_number.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100));

CREATE FUNCTION sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.gift_card_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_number = _gift_card_number
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_item_selling_price.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_late_fee_id_by_late_fee_code.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24));

CREATE FUNCTION sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.late_fee.late_fee_id
    FROM sales.late_fee
    WHERE sales.late_fee.late_fee_code = _late_fee_code
    AND NOT sales.late_fee.deleted;    
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_order_view.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_order_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
);


CREATE FUNCTION sales.get_order_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
)
RETURNS TABLE
(
    id                              bigint,
    customer                        national character varying(500),
    value_date                      date,
    expected_date                   date,
    reference_number                national character varying(24),
    terms                           national character varying(500),
    internal_memo                   national character varying(500),
    posted_by                       national character varying(500),
    office                          national character varying(500),
    transaction_ts                  TIMESTAMP WITH TIME ZONE
)
AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE office_cte(office_id) AS 
    (
        SELECT _office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    SELECT 
        sales.orders.order_id,
        inventory.get_customer_name_by_customer_id(sales.orders.customer_id),
        sales.orders.value_date,
        sales.orders.expected_delivery_date,
        sales.orders.reference_number,
        sales.orders.terms,
        sales.orders.internal_memo,
        account.get_name_by_user_id(sales.orders.user_id)::national character varying(500) AS posted_by,
        core.get_office_name_by_office_id(office_id)::national character varying(500) AS office,
        sales.orders.transaction_timestamp
    FROM sales.orders
    WHERE 1 = 1
    AND sales.orders.value_date BETWEEN _from AND _to
    AND sales.orders.expected_delivery_date BETWEEN _expected_from AND _expected_to
    AND sales.orders.office_id IN (SELECT office_id FROM office_cte)
    AND (COALESCE(_id, 0) = 0 OR _id = sales.orders.order_id)
    AND COALESCE(LOWER(sales.orders.reference_number), '') LIKE '%' || LOWER(_reference_number) || '%' 
    AND COALESCE(LOWER(sales.orders.internal_memo), '') LIKE '%' || LOWER(_internal_memo) || '%' 
    AND COALESCE(LOWER(sales.orders.terms), '') LIKE '%' || LOWER(_terms) || '%' 
    AND LOWER(inventory.get_customer_name_by_customer_id(sales.orders.customer_id)) LIKE '%' || LOWER(_customer) || '%' 
    AND LOWER(account.get_name_by_user_id(sales.orders.user_id)) LIKE '%' || LOWER(_posted_by) || '%' 
    AND LOWER(core.get_office_name_by_office_id(sales.orders.office_id)) LIKE '%' || LOWER(_office) || '%' 
    AND NOT sales.orders.deleted;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.get_order_view(1,1, '', '11/27/2010','11/27/2016','1-1-2000','1-1-2020', null,'','','','', '');


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_payable_account_for_gift_card.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_payable_account_for_gift_card(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_for_gift_card(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_id= _gift_card_id
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_payable_account_id_by_gift_card_id.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE NOT sales.gift_cards.deleted
    AND sales.gift_cards.gift_card_id = _gift_card_id;
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_quotation_view.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_quotation_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
);

CREATE FUNCTION sales.get_quotation_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
)
RETURNS TABLE
(
    id                              bigint,
    customer                        national character varying(500),
    value_date                      date,
    expected_date                   date,
    reference_number                national character varying(24),
    terms                           national character varying(500),
    internal_memo                   national character varying(500),
    posted_by                       national character varying(500),
    office                          national character varying(500),
    transaction_ts                  TIMESTAMP WITH TIME ZONE
)
AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE office_cte(office_id) AS 
    (
        SELECT _office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    SELECT 
        sales.quotations.quotation_id,
        inventory.get_customer_name_by_customer_id(sales.quotations.customer_id),
        sales.quotations.value_date,
        sales.quotations.expected_delivery_date,
        sales.quotations.reference_number,
        sales.quotations.terms,
        sales.quotations.internal_memo,
        account.get_name_by_user_id(sales.quotations.user_id)::national character varying(500) AS posted_by,
        core.get_office_name_by_office_id(office_id)::national character varying(500) AS office,
        sales.quotations.transaction_timestamp
    FROM sales.quotations
    WHERE 1 = 1
    AND sales.quotations.value_date BETWEEN _from AND _to
    AND sales.quotations.expected_delivery_date BETWEEN _expected_from AND _expected_to
    AND sales.quotations.office_id IN (SELECT office_id FROM office_cte)
    AND (COALESCE(_id, 0) = 0 OR _id = sales.quotations.quotation_id)
    AND COALESCE(LOWER(sales.quotations.reference_number), '') LIKE '%' || LOWER(_reference_number) || '%' 
    AND COALESCE(LOWER(sales.quotations.internal_memo), '') LIKE '%' || LOWER(_internal_memo) || '%' 
    AND COALESCE(LOWER(sales.quotations.terms), '') LIKE '%' || LOWER(_terms) || '%' 
    AND LOWER(inventory.get_customer_name_by_customer_id(sales.quotations.customer_id)) LIKE '%' || LOWER(_customer) || '%' 
    AND LOWER(account.get_name_by_user_id(sales.quotations.user_id)) LIKE '%' || LOWER(_posted_by) || '%' 
    AND LOWER(core.get_office_name_by_office_id(sales.quotations.office_id)) LIKE '%' || LOWER(_office) || '%' 
    AND NOT sales.quotations.deleted;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.get_quotation_view(1,1,'','11/27/2010','11/27/2016','1-1-2000','1-1-2020', null,'','','','', '');


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_receivable_account_for_check_receipts.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_receivable_account_for_check_receipts(_store_id integer);

CREATE FUNCTION sales.get_receivable_account_for_check_receipts(_store_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.stores.default_account_id_for_checks
    FROM inventory.stores
    WHERE inventory.stores.store_id = _store_id
    AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_selling_price.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_top_selling_products_of_all_time.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_top_selling_products_of_all_time(_office_id int);

CREATE FUNCTION sales.get_top_selling_products_of_all_time(_office_id int)
RETURNS TABLE
(
    id              integer,
    item_id         integer,
    item_code       text,
    item_name       text,
    total_sales     numeric
)
AS
$$
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS top_selling_products_of_all_time
    (
        id              integer,
        item_id         integer,
        item_code       text,
        item_name       text,
        total_sales     numeric
    ) ON COMMIT DROP;

    INSERT INTO top_selling_products_of_all_time(id, item_id, total_sales)
    SELECT ROW_NUMBER() OVER(), *
    FROM
    (
        SELECT         
                inventory.verified_checkout_view.item_id, 
                SUM((price * quantity) - COALESCE(discount, 0) + COALESCE(shipping_charge)) AS sales_amount
        FROM inventory.verified_checkout_view
        WHERE inventory.verified_checkout_view.office_id = _office_id
        AND inventory.verified_checkout_view.book ILIKE 'sales%'
        GROUP BY inventory.verified_checkout_view.item_id
        ORDER BY 2 DESC
        LIMIT 10
    ) t;

    UPDATE top_selling_products_of_all_time AS t
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name
    FROM inventory.items
    WHERE t.item_id = inventory.items.item_id;
    
    RETURN QUERY
    SELECT * FROM top_selling_products_of_all_time;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.get_top_selling_products_of_all_time(1);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_cash_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_cash_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,
    _value_date                                 date,
    _book_date                                  date,
    _receivable                                 public.money_strict2,
    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_cash_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,
    _value_date                                 date,
    _book_date                                  date,
    _receivable                                 public.money_strict2,
    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
BEGIN
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book, _value_date) THEN
        RETURN 0;
    END IF;

    IF(_tender < _receivable) THEN
        RAISE EXCEPTION 'The tendered amount must be greater than or equal to sales amount';
    END IF;
    
    _debit                                  := _receivable;
    _lc_debit                               := _receivable * _exchange_rate_debit;

    _credit                                 := _receivable * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _receivable * _exchange_rate_debit;
    
    INSERT INTO finance.transaction_master
    (
        transaction_master_id, 
        transaction_counter, 
        transaction_code, 
        book, 
        value_date, 
        book_date,
        user_id, 
        login_id, 
        office_id, 
        cost_center_id, 
        reference_number, 
        statement_reference,
        audit_user_id,
        cascading_tran_id
    )
    SELECT 
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _cash_account_id, _statement_reference, _cash_repository_id, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date,  book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, cash_repository_id, posted_date, tender, change, amount)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _cash_repository_id, _value_date, _tender, _change, _receivable;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.post_cash_receipt(1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, 1, 1, '1-1-2020', '1-1-2020', 2000, 0, NULL);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_check_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_check_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(_store_id)
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _check_amount                               public.money_strict2,
    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_check_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(_store_id)
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _check_amount                               public.money_strict2,
    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
BEGIN            
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book, _value_date) THEN
        RETURN 0;
    END IF;

    _debit                                  := _check_amount;
    _lc_debit                               := _check_amount * _exchange_rate_debit;

    _credit                                 := _check_amount * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _check_amount * _exchange_rate_debit;
    
    INSERT INTO finance.transaction_master
    (
        transaction_master_id, 
        transaction_counter, 
        transaction_code, 
        book, 
        value_date,
        book_date,
        user_id, 
        login_id, 
        office_id, 
        cost_center_id, 
        reference_number, 
        statement_reference,
        audit_user_id,
        cascading_tran_id
    )
    SELECT 
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _receivable_account_id, _statement_reference, NULL, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, check_amount, check_bank_name, check_number, check_date, amount)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _value_date, _check_amount, _check_bank_name, _check_number, _check_date, _check_amount;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.post_check_receipt(1, 1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, '1-1-2020', '1-1-2020', 2000, '', '', '1-1-2020', null);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_customer_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_customer_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer, 
    _currency_code                              national character varying(12), 
    _cash_account_id                            integer,
    _amount                                     public.money_strict, 
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_repository_id                         integer,
    _posted_date                                date,
    _bank_id                                    integer,
    _payment_card_id                            integer,
    _bank_instrument_code                       national character varying(128),
    _bank_tran_code                             national character varying(128)
);

CREATE FUNCTION sales.post_customer_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer, 
    _currency_code                              national character varying(12),
    _cash_account_id                            integer,
    _amount                                     public.money_strict, 
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_repository_id                         integer,
    _posted_date                                date,
    _bank_id                                    integer,
    _payment_card_id                            integer,
    _bank_instrument_code                       national character varying(128),
    _bank_tran_code                             national character varying(128)
)
RETURNS bigint
AS
$$
    DECLARE _value_date                         date;
    DECLARE _book_date                          date;
    DECLARE _book                               text;
    DECLARE _transaction_master_id              bigint;
    DECLARE _base_currency_code                 national character varying(12);
    DECLARE _local_currency_code                national character varying(12);
    DECLARE _customer_account_id                integer;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
    DECLARE _is_cash                            boolean;
    DECLARE _is_merchant                        boolean=false;
    DECLARE _merchant_rate                      public.decimal_strict2=0;
    DECLARE _customer_pays_fee                  boolean=false;
    DECLARE _merchant_fee_accont_id             integer;
    DECLARE _merchant_fee_statement_reference   text;
    DECLARE _merchant_fee                       public.money_strict2;
    DECLARE _merchant_fee_lc                    public.money_strict2;
	DECLARE _bank_account_id					integer;
BEGIN
    _value_date                             := finance.get_value_date(_office_id);
    _book_date                              := _value_date;
	_bank_account_id					    := finance.get_account_id_by_bank_account_id(_bank_id);    

    IF(finance.can_post_transaction(_login_id, _user_id, _office_id, _book, _value_date) = false) THEN
        RETURN 0;
    END IF;

    IF(_cash_repository_id > 0) THEN
        IF(_posted_date IS NOT NULL OR _bank_id IS NOT NULL OR COALESCE(_bank_instrument_code, '') != '' OR COALESCE(_bank_tran_code, '') != '') THEN
            RAISE EXCEPTION 'Invalid bank transaction information provided.'
            USING ERRCODE='P5111';
        END IF;
        _is_cash                            := true;
    END IF;

    _book                                   := 'Sales Receipt';
    
    _customer_account_id                    := inventory.get_account_id_by_customer_id(_customer_id);    
    _local_currency_code                    := core.get_currency_code_by_office_id(_office_id);
    _base_currency_code                     := inventory.get_currency_code_by_customer_id(_customer_id);


    IF EXISTS
    (
        SELECT true FROM finance.bank_accounts
        WHERE is_merchant_account
        AND bank_account_id = _bank_id
    ) THEN
        _is_merchant = true;
    END IF;

    SELECT 
        rate,
        customer_pays_fee,
        account_id,
        statement_reference
    INTO
        _merchant_rate,
        _customer_pays_fee,
        _merchant_fee_accont_id,
        _merchant_fee_statement_reference
    FROM finance.merchant_fee_setup
    WHERE merchant_account_id = _bank_id
    AND payment_card_id = _payment_card_id;

    _merchant_rate      := COALESCE(_merchant_rate, 0);
    _customer_pays_fee  := COALESCE(_customer_pays_fee, false);

    IF(_is_merchant AND COALESCE(_payment_card_id, 0) = 0) THEN
        RAISE EXCEPTION 'Invalid payment card information.'
        USING ERRCODE='P5112';
    END IF;

    IF(_merchant_rate > 0 AND COALESCE(_merchant_fee_accont_id, 0) = 0) THEN
        RAISE EXCEPTION 'Could not find an account to post merchant fee expenses.'
        USING ERRCODE='P5113';
    END IF;

    IF(_local_currency_code = _currency_code AND _exchange_rate_debit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;

    IF(_base_currency_code = _currency_code AND _exchange_rate_credit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;
        
    _debit                                  := _amount;
    _lc_debit                               := _amount * _exchange_rate_debit;

    _credit                                 := _amount * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _amount * _exchange_rate_debit;
    _merchant_fee                           := (_debit * _merchant_rate) / 100;
    _merchant_fee_lc                        := (_lc_debit * _merchant_rate)/100;
    
    INSERT INTO finance.transaction_master
    (
        transaction_master_id, 
        transaction_counter, 
        transaction_code, 
        book, 
        value_date, 
        book_date, 
        user_id, 
        login_id, 
        office_id, 
        cost_center_id, 
        reference_number, 
        statement_reference
    )
    SELECT 
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    IF(_is_cash) THEN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _cash_account_id, _statement_reference, _cash_repository_id, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;
    ELSE
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _bank_account_id, _statement_reference, NULL, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;        
    END IF;

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;


    IF(_is_merchant AND _merchant_rate > 0 AND _merchant_fee_accont_id > 0) THEN
        --Debit: Merchant Fee Expenses
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _merchant_fee_accont_id, _merchant_fee_statement_reference, NULL, _currency_code, _merchant_fee, _local_currency_code, _exchange_rate_debit, _merchant_fee_lc, _user_id;

        --Credit: Merchant A/C
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _bank_account_id, _merchant_fee_statement_reference, NULL, _currency_code, _merchant_fee, _local_currency_code, _exchange_rate_debit, _merchant_fee_lc, _user_id;

        IF(_customer_pays_fee) THEN
            --Debit: Party Account Id
            INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
            SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _customer_account_id, _merchant_fee_statement_reference, NULL, _currency_code, _merchant_fee, _local_currency_code, _exchange_rate_debit, _merchant_fee_lc, _user_id;

            --Credit: Reverse Merchant Fee Expenses
            INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
            SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _merchant_fee_accont_id, _merchant_fee_statement_reference, NULL, _currency_code, _merchant_fee, _local_currency_code, _exchange_rate_debit, _merchant_fee_lc, _user_id;
        END IF;
    END IF;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, amount, er_debit, er_credit, cash_repository_id, posted_date, collected_on_bank_id, collected_bank_instrument_code, collected_bank_transaction_code)
    SELECT _transaction_master_id, _customer_id, _currency_code, _amount,  _exchange_rate_debit, _exchange_rate_credit, _cash_repository_id, _posted_date, _bank_id, _bank_instrument_code, _bank_tran_code;

    PERFORM finance.auto_verify(_transaction_master_id, _office_id);
    PERFORM sales.settle_customer_due(_customer_id, _office_id);
    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;


-- SELECT * FROM sales.post_customer_receipt
-- (
--     1, --_user_id                                    integer, 
--     1, --_office_id                                  integer, 
--     1, --_login_id                                   bigint,
--     1, --_customer_id                                integer, 
--     'USD', --_currency_code                              national character varying(12), 
--     1,--    _cash_account_id                            integer,
--     100, --_amount                                     public.money_strict, 
--     1, --_exchange_rate_debit                        public.decimal_strict, 
--     1, --_exchange_rate_credit                       public.decimal_strict,
--     '', --_reference_number                           national character varying(24), 
--     '', --_statement_reference                        national character varying(128), 
--     1, --_cost_center_id                             integer,
--     1, --_cash_repository_id                         integer,
--     NULL, --_posted_date                                date,
--     NULL, --_bank_account_id                            bigint,
--     NULL, --_payment_card_id                            integer,
--     NULL, -- _bank_instrument_code                       national character varying(128),
--     NULL -- _bank_tran_code                             national character varying(128),
-- );

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_late_fee.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_late_fee(_user_id integer, _login_id bigint, _office_id integer, _value_date date);

CREATE FUNCTION sales.post_late_fee(_user_id integer, _login_id bigint, _office_id integer, _value_date date)
RETURNS void
VOLATILE
AS
$$
    DECLARE this                        RECORD;
    DECLARE _transaction_master_id      bigint;
    DECLARE _tran_counter               integer;
    DECLARE _transaction_code           text;
    DECLARE _default_currency_code      national character varying(12);
    DECLARE _book_name                  national character varying(100) = 'Late Fee';
BEGIN
    DROP TABLE IF EXISTS temp_late_fee;

    CREATE TEMPORARY TABLE temp_late_fee
    (
        transaction_master_id           bigint,
        value_date                      date,
        payment_term_id                 integer,
        payment_term_code               text,
        payment_term_name               text,        
        due_on_date                     boolean,
        due_days                        integer,
        due_frequency_id                integer,
        grace_period                    integer,
        late_fee_id                     integer,
        late_fee_posting_frequency_id   integer,
        late_fee_code                   text,
        late_fee_name                   text,
        is_flat_amount                  boolean,
        rate                            numeric(30, 6),
        due_amount                      public.money_strict2,
        late_fee                        public.money_strict2,
        customer_id                     integer,
        customer_account_id             integer,
        late_fee_account_id             integer,
        due_date                        date
    ) ON COMMIT DROP;

    WITH unpaid_invoices
    AS
    (
        SELECT 
             finance.transaction_master.transaction_master_id, 
             finance.transaction_master.value_date,
             sales.sales.payment_term_id,
             sales.payment_terms.payment_term_code,
             sales.payment_terms.payment_term_name,
             sales.payment_terms.due_on_date,
             sales.payment_terms.due_days,
             sales.payment_terms.due_frequency_id,
             sales.payment_terms.grace_period,
             sales.payment_terms.late_fee_id,
             sales.payment_terms.late_fee_posting_frequency_id,
             sales.late_fee.late_fee_code,
             sales.late_fee.late_fee_name,
             sales.late_fee.is_flat_amount,
             sales.late_fee.rate,
            0.00 as due_amount,
            0.00 as late_fee,
             sales.sales.customer_id,
            inventory.get_account_id_by_customer_id(sales.sales.customer_id) AS customer_account_id,
             sales.late_fee.account_id AS late_fee_account_id
        FROM  inventory.checkouts
        INNER JOIN sales.sales
        ON sales.sales.checkout_id = inventory.checkouts.checkout_id
        INNER JOIN  finance.transaction_master
        ON  finance.transaction_master.transaction_master_id =  inventory.checkouts.transaction_master_id
        INNER JOIN  sales.payment_terms
        ON  sales.payment_terms.payment_term_id =  sales.sales.payment_term_id
        INNER JOIN  sales.late_fee
        ON  sales.payment_terms.late_fee_id =  sales.late_fee.late_fee_id
        WHERE  finance.transaction_master.verification_status_id > 0
        AND  finance.transaction_master.book = ANY(ARRAY['Sales.Delivery', 'Sales.Direct'])
        AND  sales.sales.is_credit AND NOT  sales.sales.credit_settled
        AND  sales.sales.payment_term_id IS NOT NULL
        AND  sales.payment_terms.late_fee_id IS NOT NULL
        AND  finance.transaction_master.transaction_master_id NOT IN
        (
            SELECT  sales.late_fee_postings.transaction_master_id        --We have already posted the late fee before.
            FROM  sales.late_fee_postings
        )
    ), 
    unpaid_invoices_details
    AS
    (
        SELECT *, 
        CASE WHEN unpaid_invoices.due_on_date
        THEN unpaid_invoices.value_date + unpaid_invoices.due_days + unpaid_invoices.grace_period
        ELSE finance.get_frequency_end_date(unpaid_invoices.due_frequency_id, unpaid_invoices.value_date) +  unpaid_invoices.grace_period END as due_date
        FROM unpaid_invoices
    )


    INSERT INTO temp_late_fee
    SELECT * FROM unpaid_invoices_details
    WHERE unpaid_invoices_details.due_date <= _value_date;


    UPDATE temp_late_fee
    SET due_amount = 
    (
        SELECT
            SUM
            (
                COALESCE(inventory.checkouts.taxable_total, 0) + 
                COALESCE(inventory.checkouts.tax, 0) + 
                COALESCE(inventory.checkouts.nontaxable_total, 0) - 
                COALESCE(inventory.checkouts.discount, 0)
            )
        FROM inventory.checkouts
        WHERE  inventory.checkouts.transaction_master_id = temp_late_fee.transaction_master_id
    ) WHERE NOT temp_late_fee.is_flat_amount;

    UPDATE temp_late_fee
    SET late_fee = temp_late_fee.rate
    WHERE temp_late_fee.is_flat_amount;

    UPDATE temp_late_fee
    SET late_fee = temp_late_fee.due_amount * temp_late_fee.rate / 100
    WHERE NOT temp_late_fee.is_flat_amount;

    _default_currency_code                  :=  core.get_currency_code_by_office_id(_office_id);

    FOR this IN
    SELECT * FROM temp_late_fee
    WHERE temp_late_fee.late_fee > 0
    AND temp_late_fee.customer_account_id IS NOT NULL
    AND temp_late_fee.late_fee_account_id IS NOT NULL
    LOOP
        _transaction_master_id  := nextval(pg_get_serial_sequence(' finance.transaction_master', 'transaction_master_id'));
        _tran_counter           :=  finance.get_new_transaction_counter(_value_date);
        _transaction_code       :=  finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

        INSERT INTO  finance.transaction_master
        (
            transaction_master_id, 
            transaction_counter, 
            transaction_code, 
            book, 
            value_date, 
            user_id, 
            office_id, 
            reference_number,
            statement_reference,
            verification_status_id,
            verified_by_user_id,
            verification_reason
        ) 
        SELECT            
            _transaction_master_id, 
            _tran_counter, 
            _transaction_code, 
            _book_name, 
            _value_date, 
            _user_id, 
            _office_id,             
            this.transaction_master_id::text AS reference_number,
            this.late_fee_name AS statement_reference,
            1,
            _user_id,
            'Automatically verified by workflow.';

        INSERT INTO  finance.transaction_details
        (
            transaction_master_id,
            value_date,
            tran_type, 
            account_id, 
            statement_reference, 
            currency_code, 
            amount_in_currency, 
            er, 
            local_currency_code, 
            amount_in_local_currency
        )
        SELECT
            _transaction_master_id,
            _value_date,
            'Cr',
            this.late_fee_account_id,
            this.late_fee_name || ' (' || core.get_customer_code_by_customer_id(this.customer_id) || ')',
            _default_currency_code, 
            this.late_fee, 
            1 AS exchange_rate,
            _default_currency_code,
            this.late_fee
        UNION ALL
        SELECT
            _transaction_master_id,
            _value_date,
            'Dr',
            this.customer_account_id,
            this.late_fee_name,
            _default_currency_code, 
            this.late_fee, 
            1 AS exchange_rate,
            _default_currency_code,
            this.late_fee;

        INSERT INTO  sales.late_fee_postings(transaction_master_id, customer_id, value_date, late_fee_tran_id, amount)
        SELECT this.transaction_master_id, this.customer_id, _value_date, _transaction_master_id, this.late_fee;
    END LOOP;
END
$$
LANGUAGE plpgsql;

SELECT  finance.create_routine('POST-LF', ' sales.post_late_fee', 2500);

--SELECT * FROM  sales.post_late_fee(2, 5, 2,  finance.get_value_date(2));

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    
    _customer_id                                integer,
    _currency_code                              national character varying(12), 
    _exchange_rate_debit                        public.decimal_strict, 

    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        text, 

    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,

    _value_date                                 date,
    _book_date                                  date,
    _receipt_amount                             public.money_strict,

    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _check_amount                               public.money_strict2,

    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,

    _gift_card_number                           national character varying(100),
    _store_id                                   integer,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    
    _customer_id                                integer,
    _currency_code                              national character varying(12), 
    _exchange_rate_debit                        public.decimal_strict, 

    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        text, 

    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,

    _value_date                                 date,
    _book_date                                  date,
    _receipt_amount                             public.money_strict,

    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,

    _check_amount                               public.money_strict2,
    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,

    _gift_card_number                           national character varying(100),
    _store_id                                   integer DEFAULT NULL,
    _cascading_tran_id                          bigint DEFAULT NULL
)
RETURNS bigint
AS
$$
    DECLARE _book                               text;
    DECLARE _transaction_master_id              bigint;
    DECLARE _base_currency_code                 national character varying(12);
    DECLARE _local_currency_code                national character varying(12);
    DECLARE _customer_account_id                integer;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
    DECLARE _is_cash                            boolean;
    DECLARE _gift_card_id                       integer;
    DECLARE _receivable_account_id              integer;
BEGIN
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book, _value_date) THEN
        RETURN 0;
    END IF;

    IF(_cash_repository_id > 0 AND _cash_account_id > 0) THEN
        _is_cash                            := true;
    END IF;

    _receivable_account_id                  := sales.get_receivable_account_for_check_receipts(_store_id);
    _gift_card_id                           := sales.get_gift_card_id_by_gift_card_number(_gift_card_number);
    _customer_account_id                    := inventory.get_account_id_by_customer_id(_customer_id);    
    _local_currency_code                    := core.get_currency_code_by_office_id(_office_id);
    _base_currency_code                     := inventory.get_currency_code_by_customer_id(_customer_id);


    IF(_local_currency_code = _currency_code AND _exchange_rate_debit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;

    IF(_base_currency_code = _currency_code AND _exchange_rate_credit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;

    --raise exception     '%', _cash_account_id;

    
    IF(_tender >= _receipt_amount) THEN
        _transaction_master_id              := sales.post_cash_receipt(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _cash_account_id, _cash_repository_id, _value_date, _book_date, _receipt_amount, _tender, _change, _cascading_tran_id);
    ELSIF(_check_amount >= _receipt_amount) THEN
        _transaction_master_id              := sales.post_check_receipt(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _receivable_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _value_date, _book_date, _check_amount, _check_bank_name, _check_number, _check_date, _cascading_tran_id);
    ELSIF(_gift_card_id > 0) THEN
        _transaction_master_id              := sales.post_receipt_by_gift_card(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _value_date, _book_date, _gift_card_id, _gift_card_number, _receipt_amount, _cascading_tran_id);
    ELSE
        RAISE EXCEPTION 'Cannot post receipt. Please enter the tender amount.';    
    END IF;

    
    PERFORM finance.auto_verify(_transaction_master_id, _office_id);
    PERFORM sales.settle_customer_due(_customer_id, _office_id);
    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.post_receipt(1, 1, 1,inventory.get_customer_id_by_customer_code('APP'), 'USD', 1, 1, '', '', 1, 1, 1, '1-1-2020', '1-1-2020', 100, 0, 1000, '', '', null, '', null);
--SELECT * FROM sales.post_receipt(1,1,1,inventory.get_customer_id_by_customer_code('DEF'),'USD',1,1,'','', 1, 1, 1, '1-1-2020', '1-1-2020', 2000, 0, 0, 0, '', '', null, '123456', 1, null);


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_receipt_by_gift_card.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_receipt_by_gift_card
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _gift_card_id                               integer,
    _gift_card_number                           national character varying(100),
    _amount                                     public.money_strict,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_receipt_by_gift_card
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _gift_card_id                               integer,
    _gift_card_number                           national character varying(100),
    _amount                                     public.money_strict,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
    DECLARE _is_cash                            boolean;
    DECLARE _gift_card_payable_account_id       integer;
BEGIN        
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book, _value_date) THEN
        RETURN 0;
    END IF;

    _gift_card_payable_account_id           := sales.get_payable_account_for_gift_card(_gift_card_id);
    _debit                                  := _amount;
    _lc_debit                               := _amount * _exchange_rate_debit;

    _credit                                 := _amount * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _amount * _exchange_rate_debit;
    
    INSERT INTO finance.transaction_master
    (
        transaction_master_id, 
        transaction_counter, 
        transaction_code, 
        book, 
        value_date, 
        book_date,
        user_id, 
        login_id, 
        office_id, 
        cost_center_id, 
        reference_number, 
        statement_reference,
        audit_user_id,
        cascading_tran_id
    )
    SELECT 
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _gift_card_payable_account_id, _statement_reference, NULL, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, gift_card_number, amount)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _value_date, _gift_card_number, _amount;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--select * from sales.post_receipt_by_gift_card(1,1, 1,1,1,'USD','USD','USD',1,1,'','',1,'1-1-2020', '1-1-2020', 1, '123456', 1000, NULL);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_return.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_return
(
    _transaction_master_id          bigint,
    _office_id                      integer,
    _user_id                        integer,
    _login_id                       bigint,
    _value_date                     date,
    _book_date                      date,
    _store_id                       integer,
    _counter_id                     integer,
    _customer_id                    integer,
    _price_type_id                  integer,
    _reference_number               national character varying(24),
    _statement_reference            national character varying(2000),
    _details                        sales.sales_detail_type[],
	_shipper_id						integer,
	_discount						numeric(30, 6)
);

CREATE FUNCTION sales.post_return
(
    _transaction_master_id          bigint,
    _office_id                      integer,
    _user_id                        integer,
    _login_id                       bigint,
    _value_date                     date,
    _book_date                      date,
    _store_id                       integer,
    _counter_id                     integer,
    _customer_id                    integer,
    _price_type_id                  integer,
    _reference_number               national character varying(24),
    _statement_reference            national character varying(2000),
    _details                        sales.sales_detail_type[],
	_shipper_id						integer,
	_discount						numeric(30, 6)
)
RETURNS bigint
AS
$$
	DECLARE _reversal_tran_id		bigint;
	DECLARE _new_tran_id			bigint;
    DECLARE _book_name              national character varying(50) = 'Sales Return';
    DECLARE _cost_center_id         bigint;
    DECLARE _tran_counter           integer;
    DECLARE _tran_code              national character varying(50);
    DECLARE _checkout_id            bigint;
    DECLARE _grand_total            numeric(30, 6);
    DECLARE _discount_total         numeric(30, 6);
    DECLARE _is_credit              boolean;
    DECLARE _default_currency_code  national character varying(12);
    DECLARE _cost_of_goods_sold     numeric(30, 6);
    DECLARE _ck_id                  bigint;
    DECLARE _sales_id               bigint;
    DECLARE _tax_total              numeric(30, 6);
    DECLARE _tax_account_id         integer;
	DECLARE _fiscal_year_code		national character varying(12);
    DECLARE _can_post_transaction   boolean;
    DECLARE _error_message          text;
	DECLARE _original_checkout_id	bigint;
	DECLARE _original_customer_id	integer;
	DECLARE _difference				sales.sales_detail_type[];
    DECLARE _is_valid_transaction	boolean;
BEGIN
	SELECT 
		sales.sales.customer_id,
		sales.sales.checkout_id
    INTO
        _original_customer_id,
        _original_checkout_id
	FROM sales.sales
	INNER JOIN finance.transaction_master
	ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
	AND finance.transaction_master.verification_status_id > 0
	AND finance.transaction_master.transaction_master_id = _transaction_master_id;

	DROP TABLE IF EXISTS _new_checkout_items;
	CREATE TEMPORARY TABLE _new_checkout_items
	(
		store_id					integer,
		transaction_type			national character varying(2),
		item_id						integer,
		quantity					numeric(30, 6),
		unit_id						integer,
        base_quantity				numeric(30, 6),
        base_unit_id                integer,                
		price						numeric(30, 6),
		discount_rate				numeric(30, 6),
		discount					numeric(30, 6),
		shipping_charge				numeric(30, 6)
	) ON COMMIT DROP;
            
    IF NOT finance.can_post_transaction(_login_id, _user_id, _office_id, _book_name, _value_date) THEN
        RETURN 0;
    END IF;

    _tax_account_id             := finance.get_sales_tax_account_id_by_office_id(_office_id);

    
    IF(_original_customer_id IS NULL) THEN
        RAISE EXCEPTION '%', 'Invalid transaction.';
    END IF;

    IF(_original_customer_id != _customer_id) THEN
        RAISE EXCEPTION '%', 'This customer is not associated with the sales you are trying to return.';
    END IF;

    IF(NOT sales.validate_items_for_return(_transaction_master_id, _details))THEN
        RETURN 0;
    END IF;

    _default_currency_code      := core.get_currency_code_by_office_id(_office_id);
    _tran_counter               := finance.get_new_transaction_counter(_value_date);
    _tran_code                  := finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

    SELECT _sales_id = sales.sales.sales_id 
    FROM sales.sales
    WHERE sales.sales.transaction_master_id = @transaction_master_id;




    --Returned items are subtracted
    INSERT INTO _new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
    SELECT store_id, item_id, quantity *-1, unit_id, price *-1, discount_rate, shipping_charge *-1
    FROM _details;

    --Original items are added
    INSERT INTO _new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
    SELECT 
        inventory.checkout_details.store_id, 
        inventory.checkout_details.item_id,
        inventory.checkout_details.quantity,
        inventory.checkout_details.unit_id,
        inventory.checkout_details.price,
        inventory.checkout_details.discount_rate,
        inventory.checkout_details.shipping_charge
    FROM inventory.checkout_details
    WHERE checkout_id = _original_checkout_id;

    UPDATE _new_checkout_items 
    SET
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id),
        discount                        = ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2);


    IF EXISTS
    (
        SELECT item_id, COUNT(DISTINCT unit_id) 
        FROM _new_checkout_items
        GROUP BY item_id
        HAVING COUNT(DISTINCT unit_id) > 1
    ) THEN    
        RAISE EXCEPTION '%', 'A return entry must exactly macth the unit of measure provided during sales.';
    END IF;

    IF EXISTS
    (
        SELECT item_id, COUNT(DISTINCT ABS(price))
        FROM _new_checkout_items
        GROUP BY item_id
        HAVING COUNT(DISTINCT ABS(price)) > 1
    ) THEN
        RAISE EXCEPTION '%', 'A return entry must exactly macth the price provided during sales.';
    END IF;


    IF EXISTS
    (
        SELECT item_id, COUNT(DISTINCT discount_rate) 
        FROM _new_checkout_items
        GROUP BY item_id
        HAVING COUNT(DISTINCT discount_rate) > 1
    ) THEN
        RAISE EXCEPTION '%', 'A return entry must exactly macth the discount rate provided during sales.';
    END IF;


    IF EXISTS
    (
        SELECT item_id, COUNT(DISTINCT store_id) 
        FROM _new_checkout_items
        GROUP BY item_id
        HAVING COUNT(DISTINCT store_id) > 1
    ) THEN
        RAISE EXCEPTION '%', 'A return entry must exactly macth the store provided during sales.';
    END IF;

    --INSERT INTO _difference(store_id, transaction_type, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
    SELECT 
        ARRAY[ROW(store_id, 'Cr', item_id, SUM(quantity), unit_id, SUM(price), discount_rate, SUM(shipping_charge))::sales.sales_detail_type]
    INTO
        _difference
    FROM _new_checkout_items
    GROUP BY store_id, item_id, unit_id, discount_rate;

        
    DELETE FROM _difference
    WHERE quantity = 0;

    --> REVERSE THE ORIGINAL TRANSACTION
    INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
    SELECT _tran_counter, _tran_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference
    RETURNING finance.transaction_master.transaction_master_id INTO _reversal_tran_id;

    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 
        _reversal_tran_id, 
        office_id, 
        value_date, 
        book_date, 
        CASE WHEN tran_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
        account_id, 
        _statement_reference, 
        currency_code, 
        amount_in_currency, 
        er, 
        local_currency_code, 
        amount_in_local_currency
    FROM finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = _transaction_master_id;


    IF EXISTS(SELECT * FROM _difference) THEN
        --> ADD A NEW SALES INVOICE
        _new_tran_id := sales.post_sales
        (
            _office_id,
            _user_id,
            _login_id,
            _counter_id,
            _value_date,
            _book_date,
            _cost_center_id,
            _reference_number,
            _statement_reference,
            NULL, --_tender,
            NULL, --_change,
            NULL, --_payment_term_id,
            NULL, --_check_amount,
            NULL, --_check_bank_name,
            NULL, --_check_number,
            NULL, --_check_date,
            NULL, --_gift_card_number,
            _customer_id,
            _price_type_id,
            _shipper_id,
            _store_id,
            NULL, --_coupon_code,
            1, --_is_flat_discount,
            _discount,
            _difference,
            NULL, --_sales_quotation_id,
            NULL, --_sales_order_id,
            _book_name
        );
    ELSE
        _tran_counter               := finance.get_new_transaction_counter(_value_date);
        _tran_code                  := finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
        SELECT _tran_counter, _tran_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference
        RETURNING finance.transaction_master.transaction_master_id INTO _new_tran_id;
    END IF;
    
    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, office_id, posted_by, discount, taxable_total, tax_rate, tax, nontaxable_total) 
    SELECT _book_name, _value_date, _book_date, _new_tran_id, office_id, _user_id, discount, taxable_total, tax_rate, tax, nontaxable_total
    FROM inventory.checkouts
    WHERE inventory.checkouts.checkout_id = _original_checkout_id
    RETURNING inventory.checkouts.checkout_id INTO _checkout_id;

    INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount)
    SELECT _value_date, _book_date, _checkout_id, 
    CASE WHEN transaction_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
    store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount
    FROM inventory.checkout_details
    WHERE inventory.checkout_details.checkout_id = _original_checkout_id;

    INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
    SELECT _sales_id, _checkout_id, _transaction_master_id, _new_tran_id, _counter_id, _customer_id, _price_type_id;

    RETURN _new_tran_id;

END
$$
LANGUAGE plpgsql;


-- SELECT * FROM sales.post_return
-- (
--     12::bigint, --_transaction_master_id          bigint,
--     1::integer, --_office_id                      integer,
--     1::integer, --_user_id                        integer,
--     11::bigint, --_login_id                       bigint,
--     finance.get_value_date(1), --_value_date                     date,
--     finance.get_value_date(1), --_book_date                      date,
--     1::integer, --_store_id                       integer,
--     1::integer, --_counter_id                       integer,
--     1::integer, --_customer_id                    integer,
--     1::integer, --_price_type_id                  integer,
--     ''::national character varying(24), --_reference_number               national character varying(24),
--     ''::text, --_statement_reference            text,
--     ARRAY
--     [
--         ROW(1, 'Dr', 1, 1, 1,1, 0, 10, 200)::sales.sales_detail_type,
--         ROW(1, 'Dr', 2, 1, 7,1, 300, 10, 30)::sales.sales_detail_type,
--         ROW(1, 'Dr', 3, 1, 1,1, 5000, 10, 50)::sales.sales_detail_type
--     ],
--      1, 0
-- );
-- 


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_sales.sql --<--<--
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

    _tax_account_id                         := finance.get_sales_tax_account_id_by_office_id(_office_id);
    _default_currency_code                  := core.get_currency_code_by_office_id(_office_id);
    _cash_account_id                        := inventory.get_cash_account_id_by_store_id(_store_id);
    _cash_repository_id                     := inventory.get_cash_repository_id_by_store_id(_store_id);
    _is_cash                                := finance.is_cash_account_id(_cash_account_id);    

    _coupon_id                              := sales.get_active_coupon_id_by_coupon_code(_coupon_code);
    _gift_card_id                           := sales.get_gift_card_id_by_gift_card_number(_gift_card_number);
    _gift_card_balance                      := sales.get_gift_card_balance(_gift_card_id, _value_date);


    SELECT finance.tax_setups.sales_tax_rate
    INTO _sales_tax_rate 
    FROM finance.tax_setups
    WHERE NOT finance.tax_setups.deleted
    AND finance.tax_setups.office_id = _office_id;

    SELECT finance.fiscal_year.fiscal_year_code INTO _fiscal_year_code
    FROM finance.fiscal_year
    WHERE _value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on
    LIMIT 1;

    IF(COALESCE(_customer_id, 0) = 0) THEN
        RAISE EXCEPTION 'Please select a customer.';
    END IF;

    IF(COALESCE(_coupon_code, '') != '' AND COALESCE(_discount, 0) > 0) THEN
        RAISE EXCEPTION 'Please do not specify discount rate when you mention coupon code.';
    END IF;
    --TODO: VALIDATE COUPON CODE AND POST DISCOUNT

    IF(COALESCE(_payment_term_id, 0) > 0) THEN
        _is_credit                          := true;
    END IF;

    IF(NOT _is_credit AND NOT _is_cash) THEN
        RAISE EXCEPTION 'Cannot post sales. Invalid cash account mapping on store.'
        USING ERRCODE='P1302';
    END IF;

   
    IF(NOT _is_cash) THEN
        _cash_repository_id                 := NULL;
    END IF;

    DROP TABLE IF EXISTS temp_checkout_details CASCADE;
    CREATE TEMPORARY TABLE temp_checkout_details
    (
        id                              SERIAL PRIMARY KEY,
        checkout_id                     bigint, 
        tran_type                       national character varying(2), 
        store_id                        integer,
        item_id                         integer, 
        quantity                        public.decimal_strict,        
        unit_id                         integer,
        base_quantity                   numeric(30, 6),
        base_unit_id                    integer,                
        price                           public.money_strict,
        cost_of_goods_sold              public.money_strict2 DEFAULT(0),
        discount_rate                   public.decimal_strict2,
        discount                        public.money_strict2,
        is_taxed                        boolean,
        is_taxable_item                 boolean,
        amount                          public.money_strict2,
        shipping_charge                 public.money_strict2,
        sales_account_id                integer,
        sales_discount_account_id       integer,
        inventory_account_id            integer,
        cost_of_goods_sold_account_id   integer
    ) ON COMMIT DROP;

    INSERT INTO temp_checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
    FROM explode_array(_details);
    
    UPDATE temp_checkout_details 
    SET
        tran_type                       = 'Cr',
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id);

    UPDATE temp_checkout_details
    SET
        discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
    WHERE COALESCE(discount, 0) = 0;

    UPDATE temp_checkout_details
    SET
        discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
    WHERE COALESCE(discount_rate, 0) = 0;

    UPDATE temp_checkout_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

    UPDATE temp_checkout_details 
    SET is_taxable_item = inventory.items.is_taxable_item
    FROM inventory.items
    WHERE inventory.items.item_id = temp_checkout_details.item_id;

    UPDATE temp_checkout_details
    SET amount = (COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0);

    IF EXISTS
    (
        SELECT 1
        FROM temp_checkout_details
        WHERE amount < 0
    ) THEN
        RAISE EXCEPTION '%', 'A line amount cannot be less than zero.';
    END IF;

    DROP TABLE IF EXISTS item_quantities_temp;
    CREATE TEMPORARY TABLE item_quantities_temp
    (
        item_id             integer,
        base_unit_id        integer,
        store_id            integer,
        total_sales         numeric(30, 6),
        in_stock            numeric(30, 6),
        maintain_inventory      boolean
    ) ON COMMIT DROP;

    INSERT INTO item_quantities_temp(item_id, base_unit_id, store_id, total_sales)
    SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
    FROM temp_checkout_details
    GROUP BY item_id, base_unit_id, store_id;

    UPDATE item_quantities_temp
    SET maintain_inventory = inventory.items.maintain_inventory
    FROM inventory.items
    WHERE item_quantities_temp.item_id = inventory.items.item_id;
    
    UPDATE item_quantities_temp
    SET in_stock = inventory.count_item_in_stock(item_quantities_temp.item_id, item_quantities_temp.base_unit_id, item_quantities_temp.store_id)
    WHERE maintain_inventory;


    IF EXISTS
    (
        SELECT 0 FROM item_quantities_temp
        WHERE total_sales > in_stock
        AND maintain_inventory
        LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Insufficient item quantity'
        USING ERRCODE='P5500';
    END IF;
    
    IF EXISTS
    (
        SELECT 1 FROM temp_checkout_details AS details
        WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = false
        LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Item/unit mismatch.'
        USING ERRCODE='P3201';
    END IF;

    SELECT 
        COALESCE(SUM(CASE WHEN is_taxable_item = true THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
        COALESCE(SUM(CASE WHEN is_taxable_item = false THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
    INTO
        _taxable_total,
        _nontaxable_total
    FROM temp_checkout_details;

    SELECT ROUND(SUM(COALESCE(discount, 0)), 2)                 INTO _discount_total FROM temp_checkout_details;
    SELECT SUM(COALESCE(shipping_charge, 0))                    INTO _shipping_charge FROM temp_checkout_details;

        
    _coupon_discount                := ROUND(_discount, 2);

    IF(NOT _is_flat_discount AND COALESCE(_discount, 0) > 0) THEN
        _coupon_discount            := ROUND(COALESCE(_taxable_total, 0) * (_discount/100), 2);
    END IF;

    IF(_coupon_discount > _taxable_total) THEN
        RAISE EXCEPTION 'The coupon discount cannot be greater than total taxable amount.';
    END IF;

    _tax_total := ROUND((COALESCE(_taxable_total, 0) - COALESCE(_coupon_discount, 0)) * (_sales_tax_rate / 100), 2);     
    _grand_total := COALESCE(_taxable_total, 0) + COALESCE(_nontaxable_total, 0) + COALESCE(_tax_total, 0) - COALESCE(_discount_total, 0) - COALESCE(_coupon_discount, 0);         
    _receivable  := _grand_total;

    IF(_is_flat_discount AND _discount > _receivable) THEN
        RAISE EXCEPTION 'The discount amount cannot be greater than total amount.';
    ELSIF(NOT _is_flat_discount AND _discount > 100) THEN
        RAISE EXCEPTION 'The discount rate cannot be greater than 100.';    
    END IF;


    IF(_tender > 0) THEN
        IF(_tender < _receivable ) THEN
            RAISE EXCEPTION 'The tender amount must be greater than or equal to %.', _receivable;
        END IF;
    ELSIF(_check_amount > 0) THEN
        IF(_check_amount < _receivable ) THEN
            RAISE EXCEPTION 'The check amount must be greater than or equal to %.', _receivable;
        END IF;
    ELSIF(COALESCE(_gift_card_number, '') != '') THEN
        IF(_gift_card_balance < _receivable ) THEN
            RAISE EXCEPTION 'The gift card must have a balance of at least %.', _receivable;
        END IF;
    END IF;
    
    DROP TABLE IF EXISTS temp_transaction_details;
    CREATE TEMPORARY TABLE temp_transaction_details
    (
        transaction_master_id       BIGINT, 
        tran_type                   national character varying(2), 
        account_id                  integer NOT NULL, 
        statement_reference         text, 
        cash_repository_id          integer, 
        currency_code               national character varying(12), 
        amount_in_currency          money_strict NOT NULL, 
        local_currency_code         national character varying(12), 
        er                          decimal_strict, 
        amount_in_local_currency    money_strict
    ) ON COMMIT DROP;


    INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', sales_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM temp_checkout_details
    GROUP BY sales_account_id;

    IF(NOT _is_periodic) THEN
        --Perpetutal Inventory Accounting System

        UPDATE temp_checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);
        
        SELECT SUM(cost_of_goods_sold) INTO _cost_of_goods
        FROM temp_checkout_details;


        IF(_cost_of_goods > 0) THEN
            INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', cost_of_goods_sold_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM temp_checkout_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM temp_checkout_details
            GROUP BY inventory_account_id;
        END IF;
    END IF;

    IF(COALESCE(_tax_total, 0) > 0) THEN
        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', _tax_account_id, _statement_reference, _default_currency_code, _tax_total, 1, _default_currency_code, _tax_total;
    END IF;

    IF(COALESCE(_shipping_charge, 0) > 0) THEN
        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_shipper_id(_shipper_id), _statement_reference, _default_currency_code, _shipping_charge, 1, _default_currency_code, _shipping_charge;                
    END IF;


    IF(_discount_total > 0) THEN
        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_discount_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(discount, 0)), 1, _default_currency_code, SUM(COALESCE(discount, 0))
        FROM temp_checkout_details
        GROUP BY sales_discount_account_id
        HAVING SUM(COALESCE(discount, 0)) > 0;
    END IF;

    IF(_coupon_discount > 0) THEN
        SELECT inventory.stores.sales_discount_account_id
        INTO _sales_discount_account_id 
        FROM inventory.stores
        WHERE inventory.stores.store_id = _store_id;

        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', _sales_discount_account_id, _statement_reference, _default_currency_code, _coupon_discount, 1, _default_currency_code, _coupon_discount;
    END IF;


    INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', inventory.get_account_id_by_customer_id(_customer_id), _statement_reference, _default_currency_code, _receivable, 1, _default_currency_code, _receivable;

    
    _transaction_master_id  := nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));
    _checkout_id        := nextval(pg_get_serial_sequence('inventory.checkouts', 'checkout_id'));    
    _tran_counter           := finance.get_new_transaction_counter(_value_date);
    _transaction_code       := finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

    UPDATE temp_transaction_details     SET transaction_master_id   = _transaction_master_id;
    UPDATE temp_checkout_details           SET checkout_id         = _checkout_id;


    IF
    (
        SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
        FROM temp_transaction_details
    ) != 0 THEN
        RAISE EXCEPTION 'Could not balance the Journal Entry. Nothing was saved.';
    END IF;
    
    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT _transaction_master_id, _tran_counter, _transaction_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference;


    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT _value_date, _book_date, _office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM temp_transaction_details
    ORDER BY tran_type DESC;

    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, checkout_id, transaction_master_id, shipper_id, posted_by, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
    SELECT _book_name, _value_date, _book_date, _checkout_id, _transaction_master_id, _shipper_id, _user_id, _office_id, _coupon_discount, _taxable_total, _sales_tax_rate, _tax_total, _nontaxable_total;

    INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount_rate, discount, shipping_charge, is_taxed)
    SELECT _value_date, _book_date, checkout_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, COALESCE(cost_of_goods_sold, 0), discount_rate, discount, shipping_charge, is_taxable_item 
    FROM temp_checkout_details;

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
            _transaction_master_id
        ) INTO _receipt_transaction_master_id;

        PERFORM finance.auto_verify(_receipt_transaction_master_id, _office_id);        
    ELSE
        PERFORM sales.settle_customer_due(_customer_id, _office_id);
    END IF;

    IF(_book_name = 'Sales Entry') THEN
        INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id, receipt_transaction_master_id)
        SELECT _fiscal_year_code, _invoice_number, _price_type_id, _counter_id, _receivable, _cash_repository_id, _sales_order_id, _sales_quotation_id, _transaction_master_id, _checkout_id, _customer_id, _user_id, _coupon_id, _is_flat_discount, _discount, _discount_total, _is_credit, _payment_term_id, _tender, _change, _check_number, _check_date, _check_bank_name, _check_amount, _gift_card_id, _receipt_transaction_master_id;
    END IF;
    
    PERFORM finance.auto_verify(_transaction_master_id, _office_id);

    IF _serial_number_ids IS NOT NULL THEN
        _sql := 'UPDATE inventory.serial_numbers SET sales_transaction_id = '|| _transaction_master_id
        ' WHERE serial_number_id IN (' ||_serial_number_ids|| ')';

        EXECUTE _sql;
    END IF;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;




-- SELECT * FROM sales.post_sales
-- (
--     1, 1, 11, 1, finance.get_value_date(1), finance.get_value_date(1), 1, 'asdf', 'Test', 
--     500000,2000, null, null, null, null, null, null,
--     inventory.get_customer_id_by_customer_code('JOTAY'), 1, 1, 1,
--     null, true, 1000,
--     ARRAY[
--     ROW(1, 'Cr', 1, 1, 1,180000, 0, 10, 0)::sales.sales_detail_type,
--     ROW(1, 'Cr', 2, 1, 7,130000, 0, 10, 0)::sales.sales_detail_type,
--     ROW(1, 'Cr', 3, 1, 1,110000, 0, 10, 0)::sales.sales_detail_type],
--     NULL,
--     NULL
-- );
-- 


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.refresh_materialized_views.sql --<--<--
DROP FUNCTION IF EXISTS sales.refresh_materialized_views(_user_id integer, _login_id bigint, _office_id integer, _value_date date);

CREATE FUNCTION sales.refresh_materialized_views(_user_id integer, _login_id bigint, _office_id integer, _value_date date)
RETURNS void
AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW finance.trial_balance_view;
    REFRESH MATERIALIZED VIEW inventory.verified_checkout_view;
    REFRESH MATERIALIZED VIEW finance.verified_transaction_mat_view;
    REFRESH MATERIALIZED VIEW finance.verified_cash_transaction_mat_view;
END
$$
LANGUAGE plpgsql;


SELECT finance.create_routine('REF-MV', 'sales.refresh_materialized_views', 9999);

--SELECT * FROM sales.refresh_materialized_views(1, 1, 1, '1-1-2000')

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.settle_customer_due.sql --<--<--
DROP FUNCTION IF EXISTS sales.settle_customer_due(_customer_id integer, _office_id integer);

CREATE FUNCTION sales.settle_customer_due(_customer_id integer, _office_id integer)
RETURNS void
STRICT VOLATILE
AS
$$
    DECLARE _settled_transactions           bigint[];
    DECLARE _settling_amount                numeric(30, 6);
    DECLARE _closing_balance                numeric(30, 6);
    DECLARE _total_sales                    numeric(30, 6);
    DECLARE _customer_account_id            integer = inventory.get_account_id_by_customer_id(_customer_id);
BEGIN   
    --Closing balance of the customer
    SELECT
        SUM
        (
            CASE WHEN tran_type = 'Cr' 
            THEN amount_in_local_currency 
            ELSE amount_in_local_currency  * -1 
            END
        ) INTO _closing_balance
    FROM finance.transaction_details
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND NOT finance.transaction_master.deleted
    AND finance.transaction_master.office_id = _office_id
    AND finance.transaction_details.account_id = _customer_account_id;


    --Since customer account is receivable, change the balance to debit
    _closing_balance := _closing_balance * -1;

    --Sum of total sales amount
    SELECT 
        SUM
        (
            COALESCE(inventory.checkouts.taxable_total, 0) + 
            COALESCE(inventory.checkouts.tax, 0) + 
            COALESCE(inventory.checkouts.nontaxable_total, 0) - 
            COALESCE(inventory.checkouts.discount, 0)
        ) INTO _total_sales
    FROM inventory.checkouts
    INNER JOIN sales.sales
    ON sales.sales.checkout_id = inventory.checkouts.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.office_id = _office_id
    AND sales.sales.customer_id = _customer_id;


    _settling_amount := _total_sales - _closing_balance;

    WITH all_sales
    AS
    (
        SELECT 
            inventory.checkouts.transaction_master_id,
            SUM
            (
                COALESCE(inventory.checkouts.taxable_total, 0) + 
                COALESCE(inventory.checkouts.tax, 0) + 
                COALESCE(inventory.checkouts.nontaxable_total, 0) - 
                COALESCE(inventory.checkouts.discount, 0)
            ) as due
        FROM inventory.checkouts
        INNER JOIN sales.sales
        ON sales.sales.checkout_id = inventory.checkouts.checkout_id
        INNER JOIN finance.transaction_master
        ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
        WHERE finance.transaction_master.book = ANY(ARRAY['Sales.Direct', 'Sales.Delivery'])
        AND finance.transaction_master.office_id = _office_id
        AND finance.transaction_master.verification_status_id > 0      --Approved
        AND sales.sales.customer_id = _customer_id                     --of this customer
        GROUP BY inventory.checkouts.transaction_master_id
    ),
    sales_summary
    AS
    (
        SELECT 
            transaction_master_id, 
            due, 
            SUM(due) OVER(ORDER BY transaction_master_id) AS cumulative_due
        FROM all_sales
    )

    SELECT 
        ARRAY_AGG(transaction_master_id) INTO _settled_transactions
    FROM sales_summary
    WHERE cumulative_due <= _settling_amount;

    UPDATE sales.sales
    SET credit_settled = true
    WHERE transaction_master_id = ANY(_settled_transactions);
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.validate_items_for_return.sql --<--<--
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
RETURNS boolean
AS
$$
    DECLARE _checkout_id                    bigint = 0;
    DECLARE _is_purchase                    boolean = false;
    DECLARE _item_id                        integer = 0;
    DECLARE _factor_to_base_unit            numeric(30, 6);
    DECLARE _returned_in_previous_batch     public.decimal_strict2 = 0;
    DECLARE _in_verification_queue          public.decimal_strict2 = 0;
    DECLARE _actual_price_in_root_unit      public.money_strict2 = 0;
    DECLARE _price_in_root_unit             public.money_strict2 = 0;
    DECLARE _item_in_stock                  public.decimal_strict2 = 0;
    DECLARE _error_item_id                  integer;
    DECLARE _error_quantity                 numeric(30, 6);
    DECLARE _error_unit                     text;
    DECLARE _error_amount                   numeric(30, 6);
    DECLARE this                            RECORD; 
BEGIN        
    _checkout_id                            := inventory.get_checkout_id_by_transaction_master_id(_transaction_master_id);

    DROP TABLE IF EXISTS details_temp;
    CREATE TEMPORARY TABLE details_temp
    (
        store_id            integer,
        item_id             integer,
        item_in_stock       numeric(30, 6),
        quantity            public.decimal_strict,        
        unit_id             integer,
        price               public.money_strict,
        discount_rate       public.decimal_strict2,
        tax                 money_strict2,
        shipping_charge     money_strict2,
        root_unit_id        integer,
        base_quantity       numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO details_temp(store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge
    FROM explode_array(_details);

    UPDATE details_temp
    SET 
        item_in_stock = inventory.count_item_in_stock(item_id, unit_id, store_id);
       
    UPDATE details_temp
    SET root_unit_id = inventory.get_root_unit_id(unit_id);

    UPDATE details_temp
    SET base_quantity = inventory.convert_unit(unit_id, root_unit_id) * quantity;


    --Determine whether the quantity of the returned item(s) is less than or equal to the same on the actual transaction
    DROP TABLE IF EXISTS item_summary_temp;
    CREATE TEMPORARY TABLE item_summary_temp
    (
        store_id                    integer,
        item_id                     integer,
        root_unit_id                integer,
        returned_quantity           numeric(30, 6),
        actual_quantity             numeric(30, 6),
        returned_in_previous_batch  numeric(30, 6),
        in_verification_queue       numeric(30, 6)
    ) ON COMMIT DROP;
    
    INSERT INTO item_summary_temp(store_id, item_id, root_unit_id, returned_quantity)
    SELECT
        store_id,
        item_id,
        root_unit_id, 
        SUM(base_quantity)
    FROM details_temp
    GROUP BY 
        store_id, 
        item_id,
        root_unit_id;

    UPDATE item_summary_temp
    SET actual_quantity = 
    (
        SELECT SUM(base_quantity)
        FROM inventory.checkout_details
        WHERE inventory.checkout_details.checkout_id = _checkout_id
        AND inventory.checkout_details.item_id = item_summary_temp.item_id
    );

    UPDATE item_summary_temp
    SET returned_in_previous_batch = 
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
        AND item_id = item_summary_temp.item_id
    );

    UPDATE item_summary_temp
    SET in_verification_queue =
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
        AND item_id = item_summary_temp.item_id
    );
    
    --Determine whether the price of the returned item(s) is less than or equal to the same on the actual transaction
    DROP TABLE IF EXISTS cumulative_pricing_temp;
    CREATE TEMPORARY TABLE cumulative_pricing_temp
    (
        item_id                     integer,
        base_price                  numeric(30, 6),
        allowed_returns             numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO cumulative_pricing_temp
    SELECT 
        item_id,
        MIN(price  / base_quantity * quantity) as base_price,
        SUM(base_quantity) OVER(ORDER BY item_id, base_quantity) as allowed_returns
    FROM inventory.checkout_details 
    WHERE checkout_id = _checkout_id
    GROUP BY item_id, base_quantity;

    IF EXISTS(SELECT 0 FROM details_temp WHERE store_id IS NULL OR store_id <= 0) THEN
        RAISE EXCEPTION 'Invalid store.'
        USING ERRCODE='P3012';
    END IF;

    IF EXISTS(SELECT 0 FROM details_temp WHERE item_id IS NULL OR item_id <= 0) THEN
        RAISE EXCEPTION 'Invalid item.'
        USING ERRCODE='P3051';
    END IF;

    IF EXISTS(SELECT 0 FROM details_temp WHERE unit_id IS NULL OR unit_id <= 0) THEN
        RAISE EXCEPTION 'Invalid unit.'
        USING ERRCODE='P3052';
    END IF;

    IF EXISTS(SELECT 0 FROM details_temp WHERE quantity IS NULL OR quantity <= 0) THEN
        RAISE EXCEPTION 'Invalid quantity.'
        USING ERRCODE='P3301';
    END IF;

    IF(_checkout_id  IS NULL OR _checkout_id  <= 0) THEN
        RAISE EXCEPTION 'Invalid transaction id.'
        USING ERRCODE='P3302';
    END IF;

    IF NOT EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE transaction_master_id = _transaction_master_id
        AND verification_status_id > 0
    ) THEN
        RAISE EXCEPTION 'Invalid or rejected transaction.'
        USING ERRCODE='P5301';
    END IF;
        
    SELECT item_id INTO _item_id
    FROM details_temp
    WHERE item_id NOT IN
    (
        SELECT item_id FROM inventory.checkout_details
        WHERE checkout_id = _checkout_id
    )
    LIMIT 1;

    IF(COALESCE(_item_id, 0) != 0) THEN
        RAISE EXCEPTION '%', format('The item %1$s is not associated with this transaction.', inventory.get_item_name_by_item_id(_item_id))
        USING ERRCODE='P4020';
    END IF;


    IF NOT EXISTS
    (
        SELECT * FROM inventory.checkout_details
        INNER JOIN details_temp
        ON inventory.checkout_details.item_id = details_temp.item_id
        WHERE checkout_id = _checkout_id
        AND inventory.get_root_unit_id(details_temp.unit_id) = inventory.get_root_unit_id(inventory.checkout_details.unit_id)
        LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Invalid or incompatible unit specified'
        USING ERRCODE='P3053';
    END IF;

    SELECT 
        item_id,
        returned_quantity,
        inventory.get_unit_name_by_unit_id(root_unit_id)
    INTO
        _error_item_id,
        _error_quantity,
        _error_unit
    FROM item_summary_temp
    WHERE returned_quantity + returned_in_previous_batch + in_verification_queue > actual_quantity
    LIMIT 1;

    IF(_error_item_id IS NOT NULL) THEN    
        RAISE EXCEPTION 'The returned quantity (% %) of % is greater than actual quantity.', _error_quantity, _error_unit, inventory.get_item_name_by_item_id(_error_item_id)
        USING ERRCODE='P5203';
    END IF;

    FOR this IN
    SELECT item_id, base_quantity, (price / base_quantity * quantity)::numeric(30, 6) as price
    FROM details_temp
    LOOP
        SELECT 
            item_id,
            base_price
        INTO
            _error_item_id,
            _error_amount
        FROM cumulative_pricing_temp
        WHERE item_id = this.item_id
        AND base_price <  this.price
        AND allowed_returns >= this.base_quantity
        LIMIT 1;
        
        IF (_error_item_id IS NOT NULL) THEN
            RAISE EXCEPTION 'The returned base amount % of % cannot be greater than actual amount %.', this.price, inventory.get_item_name_by_item_id(_error_item_id), _error_amount
            USING ERRCODE='P5204';

            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END
$$
LANGUAGE plpgsql;

-- SELECT * FROM sales.validate_items_for_return
-- (
--     6,
--     ARRAY[
--         ROW(1, 'Dr', 1, 1, 1,180000, 0, 200, 0)::sales.sales_detail_type,
--         ROW(1, 'Dr', 2, 1, 7,130000, 300, 30, 0)::sales.sales_detail_type,
--         ROW(1, 'Dr', 3, 1, 1,110000, 5000, 50, 0)::sales.sales_detail_type
--     ]
-- );
-- 


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/03.menus/menus.sql --<--<--
DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Sales'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Sales'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.Sales';


SELECT * FROM core.create_app('MixERP.Sales', 'Sales', 'Sales', '1.0', 'MixERP Inc.', 'December 1, 2015', 'shipping blue', '/dashboard/sales/tasks/console', NULL::text[]);

SELECT * FROM core.create_menu('MixERP.Sales', 'Tasks', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'OpeningCash', 'Opening Cash', '/dashboard/sales/tasks/opening-cash', 'money', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesEntry', 'Sales Entry', '/dashboard/sales/tasks/entry', 'write', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'Receipt', 'Receipt', '/dashboard/sales/tasks/receipt', 'checkmark box', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesReturns', 'Sales Returns', '/dashboard/sales/tasks/return', 'minus square', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesQuotations', 'Sales Quotations', '/dashboard/sales/tasks/quotation', 'quote left', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesOrders', 'Sales Orders', '/dashboard/sales/tasks/order', 'file text outline', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesEntryVerification', 'Sales Entry Verification', '/dashboard/sales/tasks/entry/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'ReceiptVerification', 'Receipt Verification', '/dashboard/sales/tasks/receipt/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesReturnVerification', 'Sales Return Verification', '/dashboard/sales/tasks/return/verification', 'checkmark box', 'Tasks');
--SELECT * FROM core.create_menu('MixERP.Sales', 'CheckClearing', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'minus square outline', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'EOD', 'EOD', '/dashboard/sales/tasks/eod', 'money', 'Tasks');

SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerLoyalty', 'Customer Loyalty', 'square outline', 'user', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCards', 'Gift Cards', '/dashboard/sales/loyalty/gift-cards', 'gift', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'AddGiftCardFund', 'Add Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund', 'pound', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'VerifyGiftCardFund', 'Verify Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund/verification', 'checkmark', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesCoupons', 'Sales Coupons', '/dashboard/sales/loyalty/coupons', 'browser', 'Customer Loyalty');
--SELECT * FROM core.create_menu('MixERP.Sales', 'LoyaltyPointConfiguration', 'Loyalty Point Configuration', '/dashboard/sales/loyalty/points', 'selected radio', 'Customer Loyalty');

SELECT * FROM core.create_menu('MixERP.Sales', 'Setup', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerTypes', 'Customer Types', '/dashboard/sales/setup/customer-types', 'child', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'Customers', 'Customers', '/dashboard/sales/setup/customers', 'street view', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'PriceTypes', 'Price Types', '/dashboard/sales/setup/price-types', 'ruble', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'SellingPrices', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'in cart', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerwiseSellingPrices', 'Customerwise Selling Prices', '/dashboard/sales/setup/selling-prices/customer', 'in cart', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'LateFee', 'Late Fee', '/dashboard/sales/setup/late-fee', 'alarm mute', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'PaymentTerms', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'checked calendar', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'Cashiers', 'Cashiers', '/dashboard/sales/setup/cashiers', 'male', 'Setup');

SELECT * FROM core.create_menu('MixERP.Sales', 'Reports', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountReceivables', 'Account Receivables', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivables.xml', 'certificate', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AllGiftCards', 'All Gift Cards', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AllGiftCards.xml', 'certificate', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCardUsageStatement', 'Gift Card Usage Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardUsageStatement.xml', 'columns', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerAccountStatement', 'Customer Account Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerAccountStatement.xml', 'content', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'TopSellingItems', 'Top Selling Items', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/TopSellingItems.xml', 'map signs', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesByOffice', 'Sales by Office', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesByOffice.xml', 'building', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerReceipts', 'Customer Receipts', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerReceipts.xml', 'building', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'DetailedPaymentReport', 'Detailed Payment Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/DetailedPaymentReport.xml', 'bar chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCardSummary', 'Gift Card Summary', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardSummary.xml', 'list', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'QuotationStatus', 'Quotation Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/QuotationStatus.xml', 'list', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'OrderStatus', 'Order Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/OrderStatus.xml', 'bar chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesDiscountStatus', 'Sales Discount Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesDiscountStatus.xml', 'shopping basket icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountReceivableByCustomer', 'Account Receivable By Customer Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivableByCustomer.xml', 'list layout icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'ReceiptJournalSummary', 'Receipt Journal Summary Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ReceiptJournalSummary.xml', 'angle double left icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountantSummary', 'Accountant Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountantSummary.xml', 'address book outline icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'ClosedOut', 'Closed Out Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ClosedOut.xml', 'book icon', 'Reports');

SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Sales',
    '{*}'::text[]
);



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/04.default-values/01.default-values.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.reports/sales.get_account_receivables_report.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_account_receivables_report(_office_id integer, _from date);

CREATE FUNCTION sales.get_account_receivables_report(_office_id integer, _from date)
RETURNS TABLE
(
    office_id                   integer,
    office_name                 national character varying(500),
    account_id                  integer,
    account_number              national character varying(24),
    account_name                national character varying(500),
    previous_period             numeric(30, 6),
    current_period              numeric(30, 6),
    total_amount                numeric(30, 6)
)
AS
$$
BEGIN
    DROP TABLE IF EXISTS _results;
    
    CREATE TEMPORARY TABLE _results
    (
        office_id                   integer,
        office_name                 national character varying(500),
        account_id                  integer,
        account_number              national character varying(24),
        account_name                national character varying(500),
        previous_period             numeric(30, 6),
        current_period              numeric(30, 6),
        total_amount                numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _results(account_id, office_name, office_id)
    SELECT DISTINCT inventory.customers.account_id, core.get_office_name_by_office_id(_office_id), _office_id FROM inventory.customers;

    UPDATE _results
    SET
        account_number  = finance.accounts.account_number,
        account_name    = finance.accounts.account_name
    FROM finance.accounts
    WHERE finance.accounts.account_id = _results.account_id;


    UPDATE _results AS results
    SET previous_period = 
    (        
        SELECT 
            SUM
            (
                CASE WHEN finance.verified_transaction_view.tran_type = 'Dr' THEN
                finance.verified_transaction_view.amount_in_local_currency
                ELSE
                finance.verified_transaction_view.amount_in_local_currency * -1
                END                
            ) AS amount
        FROM finance.verified_transaction_view
        WHERE finance.verified_transaction_view.value_date < _from
        AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
        AND finance.verified_transaction_view.account_id IN
        (
            SELECT * FROM finance.get_account_ids(results.account_id)
        )
    );

    UPDATE _results AS results
    SET current_period = 
    (        
        SELECT 
            SUM
            (
                CASE WHEN finance.verified_transaction_view.tran_type = 'Dr' THEN
                finance.verified_transaction_view.amount_in_local_currency
                ELSE
                finance.verified_transaction_view.amount_in_local_currency * -1
                END                
            ) AS amount
        FROM finance.verified_transaction_view
        WHERE finance.verified_transaction_view.value_date >= _from
        AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
        AND finance.verified_transaction_view.account_id IN
        (
            SELECT * FROM finance.get_account_ids(results.account_id)
        )
    );

    UPDATE _results
    SET total_amount = COALESCE(_results.previous_period, 0) + COALESCE(_results.current_period, 0);
    
    DELETE FROM _results
    WHERE COALESCE(_results.previous_period, 0) = 0
    AND COALESCE(_results.current_period, 0) = 0
    AND COALESCE(_results.total_amount, 0) = 0;
    
    RETURN QUERY
    SELECT * FROM _results;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.get_account_receivables_report(1, '1-1-2000');


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.cashier_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.cashier_scrud_view;

CREATE VIEW sales.cashier_scrud_view
AS
SELECT
    sales.cashiers.cashier_id,
    sales.cashiers.cashier_code,
    account.users.name AS associated_user,
    inventory.counters.counter_code || ' (' || inventory.counters.counter_name || ')' AS counter,
    sales.cashiers.valid_from,
    sales.cashiers.valid_till
FROM sales.cashiers
INNER JOIN account.users
ON account.users.user_id = sales.cashiers.associated_user_id
INNER JOIN inventory.counters
ON inventory.counters.counter_id = sales.cashiers.counter_id
WHERE NOT sales.cashiers.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.item_selling_price_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.item_selling_price_scrud_view;

CREATE VIEW sales.item_selling_price_scrud_view
AS
SELECT 
    sales.item_selling_prices.item_selling_price_id,
    inventory.items.item_code || ' (' || inventory.items.item_name || ')' AS item,
    inventory.units.unit_code || ' (' || inventory.units.unit_name || ')' AS unit,
    inventory.customer_types.customer_type_code || ' (' || inventory.customer_types.customer_type_name || ')' AS customer_type,
    sales.price_types.price_type_code || ' (' || sales.price_types.price_type_name || ')' AS price_type,
    sales.item_selling_prices.includes_tax,
    sales.item_selling_prices.price
FROM sales.item_selling_prices
INNER JOIN inventory.items
ON inventory.items.item_id = sales.item_selling_prices.item_id
INNER JOIN inventory.units
ON inventory.units.unit_id = sales.item_selling_prices.unit_id
INNER JOIN inventory.customer_types
ON inventory.customer_types.customer_type_id = sales.item_selling_prices.customer_type_id
INNER JOIN sales.price_types
ON sales.price_types.price_type_id = sales.item_selling_prices.price_type_id
WHERE NOT sales.item_selling_prices.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.payment_term_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.payment_term_scrud_view;

CREATE VIEW sales.payment_term_scrud_view
AS
SELECT
    sales.payment_terms.payment_term_id,
    sales.payment_terms.payment_term_code,
    sales.payment_terms.payment_term_name,
    sales.payment_terms.due_on_date,
    sales.payment_terms.due_days,
    due_fequency.frequency_code || ' (' || due_fequency.frequency_name || ')' AS due_fequency,
    sales.payment_terms.grace_period,
    sales.late_fee.late_fee_code || ' (' || sales.late_fee.late_fee_name || ')' AS late_fee,
    late_fee_frequency.frequency_code || ' (' || late_fee_frequency.frequency_name || ')' AS late_fee_frequency
FROM sales.payment_terms
INNER JOIN finance.frequencies AS due_fequency
ON due_fequency.frequency_id = sales.payment_terms.due_frequency_id
INNER JOIN finance.frequencies AS late_fee_frequency
ON late_fee_frequency.frequency_id = sales.payment_terms.late_fee_posting_frequency_id
INNER JOIN sales.late_fee
ON sales.late_fee.late_fee_id = sales.payment_terms.late_fee_id
WHERE NOT sales.payment_terms.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/00.sales.sales_view.sql --<--<--
DROP VIEW IF EXISTS sales.sales_view;

CREATE VIEW sales.sales_view
AS
SELECT
    sales.sales.sales_id,
    sales.sales.transaction_master_id,
    finance.transaction_master.transaction_code,
    finance.transaction_master.transaction_counter,
    finance.transaction_master.value_date,
    finance.transaction_master.book_date,
	inventory.checkouts.nontaxable_total,
	inventory.checkouts.taxable_total,
    inventory.checkouts.tax_rate,
    inventory.checkouts.tax,
	inventory.checkouts.discount,
    finance.transaction_master.transaction_ts,
    finance.transaction_master.verification_status_id,
    core.verification_statuses.verification_status_name,
    finance.transaction_master.verified_by_user_id,
    account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) AS verified_by,
    sales.sales.checkout_id,
    inventory.checkouts.posted_by,
    account.get_name_by_user_id(inventory.checkouts.posted_by) AS posted_by_name,
    inventory.checkouts.office_id,
    inventory.checkouts.cancelled,
    inventory.checkouts.cancellation_reason,    
    sales.sales.cash_repository_id,
    finance.cash_repositories.cash_repository_code,
    finance.cash_repositories.cash_repository_name,
    sales.sales.price_type_id,
    sales.price_types.price_type_code,
    sales.price_types.price_type_name,
    sales.sales.counter_id,
    inventory.counters.counter_code,
    inventory.counters.counter_name,
    inventory.counters.store_id,
    inventory.stores.store_code,
    inventory.stores.store_name,
    sales.sales.customer_id,
    inventory.customers.customer_name,
    sales.sales.salesperson_id,
    account.get_name_by_user_id(sales.sales.salesperson_id) as salesperson_name,
    sales.sales.gift_card_id,
    sales.gift_cards.gift_card_number,
    sales.gift_cards.first_name || ' ' || sales.gift_cards.middle_name || ' ' || sales.gift_cards.last_name AS gift_card_owner,
    sales.sales.coupon_id,
    sales.coupons.coupon_code,
    sales.coupons.coupon_name,
    sales.sales.is_flat_discount,
    sales.sales.total_discount_amount,
    sales.sales.is_credit,
    sales.sales.payment_term_id,
    sales.payment_terms.payment_term_code,
    sales.payment_terms.payment_term_name,
    sales.sales.fiscal_year_code,
    sales.sales.invoice_number,
    sales.sales.total_amount,
    sales.sales.tender,
    sales.sales.change,
    sales.sales.check_number,
    sales.sales.check_date,
    sales.sales.check_bank_name,
    sales.sales.check_amount,
    sales.sales.reward_points
FROM sales.sales
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = sales.sales.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN finance.cash_repositories
ON finance.cash_repositories.cash_repository_id = sales.sales.cash_repository_id
INNER JOIN sales.price_types
ON sales.price_types.price_type_id = sales.sales.price_type_id
INNER JOIN inventory.counters
ON inventory.counters.counter_id = sales.sales.counter_id
INNER JOIN inventory.stores
ON inventory.stores.store_id = inventory.counters.store_id
INNER JOIN inventory.customers
ON inventory.customers.customer_id = sales.sales.customer_id
LEFT JOIN sales.gift_cards
ON sales.gift_cards.gift_card_id = sales.sales.gift_card_id
LEFT JOIN sales.payment_terms
ON sales.payment_terms.payment_term_id = sales.sales.payment_term_id
LEFT JOIN sales.coupons
ON sales.coupons.coupon_id = sales.sales.coupon_id
LEFT JOIN core.verification_statuses
ON core.verification_statuses.verification_status_id = finance.transaction_master.verification_status_id
WHERE NOT finance.transaction_master.deleted;


--SELECT * FROM sales.sales_view

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/01.sales.customer_transaction_view.sql --<--<--
DROP VIEW IF EXISTS sales.customer_transaction_view;
CREATE VIEW sales.customer_transaction_view 
AS
SELECT 
    sales_view.value_date,
    sales_view.book_date,
    sales_view.transaction_master_id,
    sales_view.transaction_code,
    sales_view.invoice_number,
    sales_view.customer_id,
    'Invoice'::text AS statement_reference,
    sales_view.total_amount::numeric + COALESCE(sales_view.check_amount::numeric, 0::numeric) - sales_view.total_discount_amount::numeric AS debit,
    NULL::numeric AS credit
FROM sales.sales_view
WHERE sales_view.verification_status_id > 0
UNION ALL

SELECT 
    sales_view.value_date,
    sales_view.book_date,
    sales_view.transaction_master_id,
    sales_view.transaction_code,
    sales_view.invoice_number,
    sales_view.customer_id,
    'Payment'::text AS statement_reference,
    NULL::numeric AS debit,
    sales_view.total_amount::numeric + COALESCE(sales_view.check_amount::numeric, 0::numeric) - sales_view.total_discount_amount::numeric AS credit
FROM sales.sales_view
WHERE sales_view.verification_status_id > 0 AND NOT sales_view.is_credit
UNION ALL

SELECT 
    sales_view.value_date,
    sales_view.book_date,
    sales_view.transaction_master_id,
    sales_view.transaction_code,
    sales_view.invoice_number,
    returns.customer_id,
    'Return'::text AS statement_reference,
    NULL::numeric AS debit,
    sum(checkout_detail_view.total) AS credit
FROM sales.returns
JOIN sales.sales_view ON returns.sales_id = sales_view.sales_id
JOIN inventory.checkout_detail_view ON returns.checkout_id = checkout_detail_view.checkout_id
WHERE sales_view.verification_status_id > 0
GROUP BY sales_view.value_date, sales_view.invoice_number, returns.customer_id, sales_view.book_date, sales_view.transaction_master_id, sales_view.transaction_code
UNION ALL

SELECT 
    customer_receipts.posted_date AS value_date,
    finance.transaction_master.book_date,
    finance.transaction_master.transaction_master_id,
    finance.transaction_master.transaction_code,
    NULL::bigint AS invoice_number,
    customer_receipts.customer_id,
    'Payment'::text AS statement_reference,
    NULL::numeric AS debit,
    customer_receipts.amount AS credit
FROM sales.customer_receipts
JOIN finance.transaction_master ON customer_receipts.transaction_master_id = transaction_master.transaction_master_id
WHERE transaction_master.verification_status_id > 0;

--SELECT * FROM sales.customer_transaction_view;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.coupon_view.sql --<--<--
DROP VIEW IF EXISTS sales.coupon_view;

CREATE VIEW sales.coupon_view
AS
SELECT
    sales.coupons.coupon_id,
    sales.coupons.coupon_code,
    sales.coupons.coupon_name,
    sales.coupons.discount_rate,
    sales.coupons.is_percentage,
    sales.coupons.maximum_discount_amount,
    sales.coupons.associated_price_type_id,
    associated_price_type.price_type_code AS associated_price_type_code,
    associated_price_type.price_type_name AS associated_price_type_name,
    sales.coupons.minimum_purchase_amount,
    sales.coupons.maximum_purchase_amount,
    sales.coupons.begins_from,
    sales.coupons.expires_on,
    sales.coupons.maximum_usage,
    sales.coupons.enable_ticket_printing,
    sales.coupons.for_ticket_of_price_type_id,
    for_ticket_of_price_type.price_type_code AS for_ticket_of_price_type_code,
    for_ticket_of_price_type.price_type_name AS for_ticket_of_price_type_name,
    sales.coupons.for_ticket_having_minimum_amount,
    sales.coupons.for_ticket_having_maximum_amount,
    sales.coupons.for_ticket_of_unknown_customers_only
FROM sales.coupons
LEFT JOIN sales.price_types AS associated_price_type
ON associated_price_type.price_type_id = sales.coupons.associated_price_type_id
LEFT JOIN sales.price_types AS for_ticket_of_price_type
ON for_ticket_of_price_type.price_type_id = sales.coupons.for_ticket_of_price_type_id;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.customer_receipt_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.customer_receipt_search_view;

CREATE VIEW sales.customer_receipt_search_view
AS
SELECT
	sales.customer_receipts.transaction_master_id::text AS tran_id,
	finance.transaction_master.transaction_code AS tran_code,
	sales.customer_receipts.customer_id,
	inventory.get_customer_name_by_customer_id(sales.customer_receipts.customer_id) AS customer,
	COALESCE(sales.customer_receipts.amount, sales.customer_receipts.check_amount, COALESCE(sales.customer_receipts.tender, 0) - COALESCE(sales.customer_receipts.change, 0)) AS amount,
	finance.transaction_master.value_date,
	finance.transaction_master.book_date,
	COALESCE(finance.transaction_master.reference_number, '') AS reference_number,
	COALESCE(finance.transaction_master.statement_reference, '') AS statement_reference,
	account.get_name_by_user_id(finance.transaction_master.user_id) AS posted_by,
	core.get_office_name_by_office_id(finance.transaction_master.office_id) AS office,
	finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) AS status,
	COALESCE(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id), '') AS verified_by,
	finance.transaction_master.last_verified_on,
	finance.transaction_master.verification_reason AS reason,
	finance.transaction_master.office_id
FROM sales.customer_receipts
INNER JOIN finance.transaction_master
ON sales.customer_receipts.transaction_master_id = finance.transaction_master.transaction_master_id
WHERE NOT finance.transaction_master.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.gift_card_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.gift_card_search_view;

CREATE VIEW sales.gift_card_search_view
AS
SELECT
    sales.gift_cards.gift_card_id,
    sales.gift_cards.gift_card_number,
    REPLACE(COALESCE(sales.gift_cards.first_name || ' ', '') || COALESCE(sales.gift_cards.middle_name || ' ', '') || COALESCE(sales.gift_cards.last_name, ''), '  ', ' ') AS name,
    REPLACE(COALESCE(sales.gift_cards.address_line_1 || ' ', '') || COALESCE(sales.gift_cards.address_line_2 || ' ', '') || COALESCE(sales.gift_cards.street, ''), '  ', ' ') AS address,
    sales.gift_cards.city,
    sales.gift_cards.state,
    sales.gift_cards.country,
    sales.gift_cards.po_box,
    sales.gift_cards.zip_code,
    sales.gift_cards.phone_numbers,
    sales.gift_cards.fax    
FROM sales.gift_cards
WHERE NOT sales.gift_cards.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.gift_card_transaction_view.sql --<--<--
DROP VIEW IF EXISTS sales.gift_card_transaction_view;

CREATE VIEW sales.gift_card_transaction_view
AS
SELECT
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_ts,
finance.transaction_master.transaction_code,
finance.transaction_master.value_date,
finance.transaction_master.book_date,
account.users.name AS entered_by,
sales.gift_cards.first_name || ' ' || sales.gift_cards.middle_name || ' ' || sales.gift_cards.last_name AS customer_name,
sales.gift_card_transactions.amount,
core.verification_statuses.verification_status_name AS status,
verified_by_user.name AS verified_by,
finance.transaction_master.verification_reason,
finance.transaction_master.last_verified_on,
core.offices.office_name,
finance.cost_centers.cost_center_name,
finance.transaction_master.reference_number,
finance.transaction_master.statement_reference,
account.get_name_by_user_id(finance.transaction_master.user_id) AS posted_by,
finance.transaction_master.office_id
FROM finance.transaction_master
INNER JOIN core.offices
ON finance.transaction_master.office_id = core.offices.office_id
INNER JOIN finance.cost_centers
ON finance.transaction_master.cost_center_id = finance.cost_centers.cost_center_id
INNER JOIN sales.gift_card_transactions
ON sales.gift_card_transactions.transaction_master_id = finance.transaction_master.transaction_master_id
INNER JOIN account.users
ON finance.transaction_master.user_id = account.users.user_id
LEFT JOIN sales.gift_cards
ON sales.gift_card_transactions.gift_card_id = sales.gift_cards.gift_card_id
INNER JOIN core.verification_statuses
ON finance.transaction_master.verification_status_id = core.verification_statuses.verification_status_id
LEFT JOIN account.users AS verified_by_user
ON finance.transaction_master.verified_by_user_id = verified_by_user.user_id;

--SELECT * FROM sales.gift_card_transaction_view;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.item_view.sql --<--<--
DROP VIEW IF EXISTS sales.item_view;

CREATE VIEW sales.item_view
AS
SELECT
    inventory.items.item_id,
    inventory.items.item_code,
    inventory.items.item_name,
    inventory.items.is_taxable_item,
    inventory.items.barcode,
    inventory.items.item_group_id,
    inventory.item_groups.item_group_name,
    inventory.item_types.item_type_id,
    inventory.item_types.item_type_name,
    inventory.items.brand_id,
    inventory.brands.brand_name,
    inventory.items.preferred_supplier_id,
    inventory.items.unit_id,
    array_to_string(inventory.get_associated_unit_list(inventory.items.unit_id), ',') AS valid_units,
    inventory.units.unit_code,
    inventory.units.unit_name,
    inventory.items.hot_item,
    inventory.items.selling_price,
    inventory.items.selling_price_includes_tax,
    inventory.items.photo
FROM inventory.items
INNER JOIN inventory.item_groups
ON inventory.item_groups.item_group_id = inventory.items.item_group_id
INNER JOIN inventory.item_types
ON inventory.item_types.item_type_id = inventory.items.item_type_id
INNER JOIN inventory.brands
ON inventory.brands.brand_id = inventory.items.brand_id
INNER JOIN inventory.units
ON inventory.units.unit_id = inventory.items.unit_id
WHERE NOT inventory.items.deleted
AND inventory.items.allow_sales;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.order_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.order_search_view;

CREATE VIEW sales.order_search_view
AS
SELECT
	sales.orders.order_id,
	inventory.get_customer_name_by_customer_id(sales.orders.customer_id) AS customer,
	sales.orders.value_date,
	sales.orders.expected_delivery_date AS expected_date,
	COALESCE(sales.orders.taxable_total, 0) + 
	COALESCE(sales.orders.tax, 0) + 
	COALESCE(sales.orders.nontaxable_total, 0) - 
	COALESCE(sales.orders.discount, 0) AS total_amount,
	COALESCE(sales.orders.reference_number, '') AS reference_number,
	COALESCE(sales.orders.terms, '') AS terms,
	COALESCE(sales.orders.internal_memo, '') AS memo,
	account.get_name_by_user_id(sales.orders.user_id) AS posted_by,
	core.get_office_name_by_office_id(sales.orders.office_id) AS office,
	sales.orders.transaction_timestamp AS posted_on,
	sales.orders.office_id,
	sales.orders.discount,
	sales.orders.tax,
	sales.orders.cancelled
FROM sales.orders;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.quotation_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.quotation_search_view;

CREATE VIEW sales.quotation_search_view
AS
SELECT
	sales.quotations.quotation_id,
	inventory.get_customer_name_by_customer_id(sales.quotations.customer_id) AS customer,
	sales.quotations.value_date,
	sales.quotations.expected_delivery_date AS expected_date,
	COALESCE(sales.quotations.taxable_total, 0) + 
	COALESCE(sales.quotations.tax, 0) + 
	COALESCE(sales.quotations.nontaxable_total, 0) - 
	COALESCE(sales.quotations.discount, 0) AS total_amount,
	COALESCE(sales.quotations.reference_number, '') AS reference_number,
	COALESCE(sales.quotations.terms, '') AS terms,
	COALESCE(sales.quotations.internal_memo, '') AS memo,
	account.get_name_by_user_id(sales.quotations.user_id) AS posted_by,
	core.get_office_name_by_office_id(sales.quotations.office_id) AS office,
	sales.quotations.transaction_timestamp AS posted_on,
	sales.quotations.office_id,
	sales.quotations.discount,
	sales.quotations.tax,
	sales.quotations.cancelled
FROM sales.quotations;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.return_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.return_search_view;

CREATE VIEW sales.return_search_view
AS
SELECT
	finance.transaction_master.transaction_master_id::text AS tran_id,
	finance.transaction_master.transaction_code AS tran_code,
	sales.returns.customer_id,
	inventory.get_customer_name_by_customer_id(sales.returns.customer_id) AS customer,
	SUM(CASE WHEN finance.transaction_details.tran_type = 'Dr' THEN finance.transaction_details.amount_in_local_currency ELSE 0 END) AS amount,
	finance.transaction_master.value_date,
	finance.transaction_master.book_date,
	COALESCE(finance.transaction_master.reference_number, '') AS reference_number,
	COALESCE(finance.transaction_master.statement_reference, '') AS statement_reference,
	account.get_name_by_user_id(finance.transaction_master.user_id) AS posted_by,
	core.get_office_name_by_office_id(finance.transaction_master.office_id) AS office,
	finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) AS status,
	COALESCE(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id), '') AS verified_by,
	finance.transaction_master.last_verified_on,
	finance.transaction_master.verification_reason AS reason,
	finance.transaction_master.office_id
FROM sales.returns
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = sales.returns.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN finance.transaction_details
ON finance.transaction_details.transaction_master_id = finance.transaction_master.transaction_master_id
WHERE NOT finance.transaction_master.deleted
GROUP BY
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_code,
sales.returns.customer_id,
finance.transaction_master.value_date,
finance.transaction_master.book_date,
finance.transaction_master.reference_number,
finance.transaction_master.statement_reference,
finance.transaction_master.user_id,
finance.transaction_master.office_id,
finance.transaction_master.verification_status_id,
finance.transaction_master.verified_by_user_id,
finance.transaction_master.last_verified_on,
finance.transaction_master.verification_reason;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.sales_search_view.sql --<--<--
DROP VIEW IF EXISTS sales.sales_search_view;

CREATE VIEW sales.sales_search_view
AS
SELECT 
    finance.transaction_master.transaction_master_id::text AS tran_id, 
    finance.transaction_master.transaction_code AS tran_code,
    finance.transaction_master.value_date,
    finance.transaction_master.book_date,
    inventory.get_customer_name_by_customer_id(sales.sales.customer_id) AS customer,
    sales.sales.total_amount,
    finance.transaction_master.reference_number,
    finance.transaction_master.statement_reference,
    account.get_name_by_user_id(finance.transaction_master.user_id) as posted_by,
    core.get_office_name_by_office_id(finance.transaction_master.office_id) as office,
    finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) as status,
    account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) as verified_by,
    finance.transaction_master.last_verified_on AS verified_on,
    finance.transaction_master.verification_reason AS reason,    
    finance.transaction_master.transaction_ts AS posted_on,
    finance.transaction_master.office_id
FROM finance.transaction_master
INNER JOIN sales.sales
ON sales.sales.transaction_master_id = finance.transaction_master.transaction_master_id
WHERE NOT finance.transaction_master.deleted
ORDER BY sales_id;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/06.widgets/inventory.top_customers_by_office_view.sql --<--<--
DROP VIEW IF EXISTS inventory.top_customers_by_office_view;

CREATE VIEW inventory.top_customers_by_office_view
AS
SELECT
    inventory.checkouts.office_id,
    sales.sales.customer_id,
    CASE WHEN COALESCE(inventory.customers.customer_name, '') = ''
    THEN inventory.customers.company_name
    ELSE inventory.customers.customer_name
    END as customer,
    inventory.customers.company_country AS country,
    SUM
    (
        COALESCE(inventory.checkouts.taxable_total, 0) +
        COALESCE(inventory.checkouts.nontaxable_total, 0) +
        COALESCE(inventory.checkouts.tax, 0) -
        COALESCE(inventory.checkouts.discount, 0)
    ) AS amount
FROM inventory.checkouts
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN sales.sales
ON sales.sales.checkout_id = inventory.checkouts.checkout_id
INNER JOIN inventory.customers
ON sales.sales.customer_id = inventory.customers.customer_id
AND finance.transaction_master.verification_status_id > 0
GROUP BY
    inventory.checkouts.office_id,
    sales.sales.customer_id,
    inventory.customers.customer_name,
    inventory.customers.company_name,
    inventory.customers.company_country
ORDER BY 5 DESC
LIMIT 5;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/06.widgets/sales.get_account_receivable_widget_details.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_account_receivable_widget_details(_office_id integer);

CREATE FUNCTION sales.get_account_receivable_widget_details(_office_id integer)
RETURNS TABLE
(
    all_time_sales                              numeric(30, 6),
    all_time_receipt                            numeric(30, 6),
    receivable_of_all_time                      numeric(30, 6),
    this_months_sales                           numeric(30, 6),
    this_months_receipt                         numeric(30, 6),
    receivable_of_this_month                    numeric(30, 6)
)
AS
$$
    DECLARE _all_time_sales                     numeric(30, 6);
    DECLARE _all_time_receipt                   numeric(30, 6);
    DECLARE _this_months_sales                  numeric(30, 6);
    DECLARE _this_months_receipt                numeric(30, 6);
    DECLARE _start_date                         date = finance.get_month_start_date(_office_id);
    DECLARE _end_date                           date = finance.get_month_end_date(_office_id);
BEGIN    
    SELECT COALESCE(SUM(sales.sales.total_amount), 0) INTO _all_time_sales 
    FROM sales.sales
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
    AND finance.transaction_master.verification_status_id > 0;
    
    SELECT COALESCE(SUM(sales.customer_receipts.amount), 0) INTO _all_time_receipt 
    FROM sales.customer_receipts
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.customer_receipts.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
    AND finance.transaction_master.verification_status_id > 0;

    SELECT COALESCE(SUM(sales.sales.total_amount), 0) INTO _this_months_sales 
    FROM sales.sales
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
    AND finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date BETWEEN _start_date AND _end_date;
    
    SELECT COALESCE(SUM(sales.customer_receipts.amount), 0) INTO _this_months_receipt 
    FROM sales.customer_receipts
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.customer_receipts.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id))
    AND finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date BETWEEN _start_date AND _end_date;


    RETURN QUERY
    SELECT _all_time_sales, _all_time_receipt, _all_time_sales - _all_time_receipt, 
    _this_months_sales, _this_months_receipt, _this_months_sales - _this_months_receipt;    
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.get_account_receivable_widget_details(1);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/99.ownership.sql --<--<--
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


