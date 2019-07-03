-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
ALTER TABLE sales.returns
ALTER COLUMN sales_id bigint NULL;

ALTER TABLE sales.returns
ALTER COLUMN transaction_master_id bigint NULL;

IF COL_LENGTH('sales.orders', 'priority') IS NULL
BEGIN
	ALTER TABLE sales.orders 
	ADD [priority] national character varying(24);
END;

IF COL_LENGTH('sales.customerwise_selling_prices', 'is_taxable') IS NULL
BEGIN
	ALTER TABLE sales.customerwise_selling_prices
	ADD is_taxable bit NOT NULL DEFAULT(0);
END;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.add_gift_card_fund.sql --<--<--
IF OBJECT_ID('sales.add_gift_card_fund') IS NOT NULL
DROP PROCEDURE sales.add_gift_card_fund;

GO

CREATE PROCEDURE sales.add_gift_card_fund
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @gift_card_number                           national character varying(500),
    @value_date                                 date,
    @book_date                                  date,
    @debit_account_id                           integer,
    @amount                                     numeric(30, 6),
    @cost_center_id                             integer,
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @gift_card_id						integer;

	SELECT TOP 1 @gift_card_id = sales.gift_cards.gift_card_id
	FROM sales.gift_cards
	WHERE sales.gift_cards.gift_card_number = @gift_card_number
	AND sales.gift_cards.deleted = 0;

    DECLARE @transaction_master_id              bigint;
    DECLARE @book_name                          national character varying(50) = 'Gift Card Fund Sales';
    DECLARE @payable_account_id                 integer = sales.get_payable_account_id_by_gift_card_id(@gift_card_id);
    DECLARE @currency_code                      national character varying(12) = core.get_currency_code_by_office_id(@office_id);


    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, cost_center_id, reference_number, statement_reference)
        SELECT
            finance.get_new_transaction_counter(@value_date),
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book_name,
            @value_date,
            @book_date,
            @login_id,
            @user_id,
            @office_id,
            @cost_center_id,
            @reference_number,
            @statement_reference;

        SET @transaction_master_id = SCOPE_IDENTITY();

        INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
        SELECT
            @transaction_master_id, 
            @value_date, 
            @book_date,
            'Cr', 
            @payable_account_id, 
            @statement_reference, 
            @currency_code, 
            @amount, 
            @currency_code, 
            1, 
            @amount, 
            @office_id, 
            @user_id;

        INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
        SELECT
            @transaction_master_id, 
            @value_date, 
            @book_date,
            'Dr', 
            @debit_account_id, 
            @statement_reference, 
            @currency_code, 
            @amount, 
            @currency_code, 
            1, 
            @amount, 
            @office_id, 
            @user_id;

        INSERT INTO sales.gift_card_transactions(gift_card_id, value_date, book_date, transaction_master_id, transaction_type, amount)
        SELECT @gift_card_id, @value_date, @book_date, @transaction_master_id, 'Cr', @amount;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.add_opening_cash.sql --<--<--
IF OBJECT_ID('sales.add_opening_cash') IS NOT NULL
DROP PROCEDURE sales.add_opening_cash;

GO

CREATE PROCEDURE sales.add_opening_cash
(
    @user_id                                integer,
    @transaction_date                       DATETIMEOFFSET,
    @amount                                 numeric(30, 6),
    @provided_by                            national character varying(1000),
    @memo                                   national character varying(4000)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sales.opening_cash
        WHERE user_id = @user_id
        AND transaction_date = @transaction_date
    )
    BEGIN
        INSERT INTO sales.opening_cash(user_id, transaction_date, amount, provided_by, memo, audit_user_id, audit_ts, deleted)
        SELECT @user_id, @transaction_date, @amount, @provided_by, @memo, @user_id, GETUTCDATE(), 0;
    END
    ELSE
    BEGIN
        UPDATE sales.opening_cash
        SET
            amount = @amount,
            provided_by = @provided_by,
            memo = @memo,
            user_id = @user_id,
            audit_user_id = @user_id,
            audit_ts = GETUTCDATE(),
            deleted = 0
        WHERE user_id = @user_id
        AND transaction_date = @transaction_date;
    END;
END

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_active_coupon_id_by_coupon_code.sql --<--<--
IF OBJECT_ID('sales.get_active_coupon_id_by_coupon_code') IS NOT NULL
DROP FUNCTION sales.get_active_coupon_id_by_coupon_code;

GO

CREATE FUNCTION sales.get_active_coupon_id_by_coupon_code(@coupon_code national character varying(100))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.coupons.coupon_id
	    FROM sales.coupons
	    WHERE sales.coupons.coupon_code = @coupon_code
	    AND COALESCE(sales.coupons.begins_from, CAST(GETUTCDATE() AS date)) >= CAST(GETUTCDATE() AS date)
	    AND COALESCE(sales.coupons.expires_on, CAST(GETUTCDATE() AS date)) <= CAST(GETUTCDATE() AS date)
	    AND sales.coupons.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_avaiable_coupons_to_print.sql --<--<--
IF OBJECT_ID('sales.get_avaiable_coupons_to_print') IS NOT NULL
DROP FUNCTION sales.get_avaiable_coupons_to_print;

GO

CREATE FUNCTION sales.get_avaiable_coupons_to_print(@tran_id bigint)
RETURNS @result TABLE
(
    coupon_id               integer
)
AS
BEGIN
    DECLARE @price_type_id                  integer;
    DECLARE @total_amount                   numeric(30, 6);
    DECLARE @customer_id                    integer;

    DECLARE @temp_coupons TABLE
    (
        coupon_id                           integer,
        maximum_usage                       integer,
        total_used                          integer
    );
    
    SELECT
        @price_type_id = sales.sales.price_type_id,
        @total_amount = sales.sales.total_amount,
        @customer_id = sales.sales.customer_id        
    FROM sales.sales
    WHERE sales.sales.transaction_master_id = @tran_id;


    INSERT INTO @temp_coupons(coupon_id, maximum_usage)
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE sales.coupons.deleted = 0
    AND sales.coupons.enable_ticket_printing = 1
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
    AND sales.coupons.for_ticket_of_price_type_id IS NULL
    AND COALESCE(sales.coupons.for_ticket_having_minimum_amount, 0) = 0
    AND COALESCE(sales.coupons.for_ticket_having_maximum_amount, 0) = 0
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    INSERT INTO @temp_coupons(coupon_id, maximum_usage)
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE sales.coupons.deleted = 0
    AND sales.coupons.enable_ticket_printing = 1
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
    AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
    AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    IF(COALESCE(@customer_id, 0) > 0)
    BEGIN
        INSERT INTO @temp_coupons(coupon_id, maximum_usage)
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE sales.coupons.deleted = 0
        AND sales.coupons.enable_ticket_printing = 1
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
        AND sales.coupons.for_ticket_of_unknown_customers_only = 0;
    END
    ELSE
    BEGIN
        INSERT INTO @temp_coupons(coupon_id, maximum_usage)
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE sales.coupons.deleted = 0
        AND sales.coupons.enable_ticket_printing = 1
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
        AND sales.coupons.for_ticket_of_unknown_customers_only = 1;    
    END;

    UPDATE @temp_coupons
    SET total_used = 
    (
        SELECT COUNT(*)
        FROM sales.sales
        WHERE sales.sales.coupon_id = coupon_id 
    );

    DELETE FROM @temp_coupons WHERE total_used > maximum_usage;
    
    INSERT INTO @result
    SELECT coupon_id FROM @temp_coupons;

    RETURN;
END;



--SELECT * FROM sales.get_avaiable_coupons_to_print(2);

GO

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_customer_account_detail.sql --<--<--
IF OBJECT_ID('sales.get_customer_account_detail') IS NOT NULL
DROP FUNCTION sales.get_customer_account_detail;

GO

CREATE FUNCTION sales.get_customer_account_detail
(
    @customer_id        integer,
    @from               date,
    @to                 date,
    @office_id          integer
)
RETURNS @result TABLE
(
    id                      integer IDENTITY, 
    value_date              date, 
    book_date               date,
    tran_id                 bigint,
    tran_code               text,
    invoice_number          bigint, 
    tran_type       text, 
    debit                   numeric(30, 6), 
    credit                  numeric(30, 6), 
    balance                 numeric(30, 6)
)
AS
BEGIN
    INSERT INTO @result
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
    WHERE customer_transaction_view.customer_id = @customer_id
    AND customers.deleted = 0
  AND sales_view.office_id = @office_id
    AND customer_transaction_view.value_date BETWEEN @from AND @to;

  UPDATE @result 
    SET balance = c.balance
  FROM @result as result
    INNER JOIN
    (
        SELECT p.id,
            SUM(COALESCE(c.debit, 0) - COALESCE(c.credit, 0)) As balance
        FROM @result p
        LEFT JOIN @result c
        ON c.id <= p.id
        GROUP BY p.id
    ) AS c
    ON result.id = c.id;
  
  RETURN;
END;

GO

--select * from sales.get_customer_account_detail(1, '1-1-2000', '1-1-2060', 1);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_gift_card_balance.sql --<--<--
IF OBJECT_ID('sales.get_gift_card_balance') IS NOT NULL
DROP FUNCTION sales.get_gift_card_balance;

GO

CREATE FUNCTION sales.get_gift_card_balance(@gift_card_id integer, @value_date date)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @debit          numeric(30, 6);
    DECLARE @credit         numeric(30, 6);

    SELECT @debit = SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Dr'
    AND finance.transaction_master.value_date <= @value_date;

    SELECT @credit = SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Cr'
    AND finance.transaction_master.value_date <= @value_date;

    --Gift cards are account payables
    RETURN COALESCE(@credit, 0) - COALESCE(@debit, 0);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_gift_card_detail.sql --<--<--
IF OBJECT_ID('sales.get_gift_card_detail') IS NOT NULL
DROP FUNCTION sales.get_gift_card_detail;
GO

CREATE FUNCTION sales.get_gift_card_detail
(
    @card_number	nvarchar(50),
    @from			date,
    @to				date,
	@office_id		integer
)
RETURNS @result TABLE
(
	id					integer IDENTITY, 
	gift_card_id		integer, 
	transaction_ts		datetime, 
	statement_reference text, 
	debit				numeric(30, 6), 
	credit				numeric(30, 6), 
	balance				numeric(30, 6)
)
AS
BEGIN
	INSERT INTO @result
	(
		gift_card_id, 
		transaction_ts, 
		statement_reference, 
		debit,
		credit
	)
	SELECT 
		gift_card_id, 
		transaction_ts, 
		statement_reference, 
		debit, 
		credit
	FROM
	(
		SELECT
			gift_card_transactions.gift_card_id,
			transaction_master.transaction_ts,
			transaction_master.statement_reference,
			CASE WHEN gift_card_transactions.transaction_type = 'Dr' THEN gift_card_transactions.amount END AS debit,
			CASE WHEN gift_card_transactions.transaction_type = 'Cr' THEN gift_card_transactions.amount END AS credit
		FROM sales.gift_card_transactions
		JOIN finance.transaction_master
			ON transaction_master.transaction_master_id = gift_card_transactions.transaction_master_id
		JOIN sales.gift_cards
			ON gift_cards.gift_card_id = gift_card_transactions.gift_card_id
		WHERE transaction_master.verification_status_id > 0
		AND transaction_master.deleted = 0
		AND transaction_master.office_id IN (SELECT office_id FROM core.get_office_ids(@office_id)) 
		AND gift_cards.gift_card_number = @card_number
		AND transaction_master.transaction_ts BETWEEN @from AND @to
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
		WHERE transaction_master.verification_status_id > 0
		AND transaction_master.deleted = 0
		AND transaction_master.office_id IN (SELECT office_id FROM core.get_office_ids(@office_id)) 
		AND sales.gift_card_id IS NOT NULL
		AND gift_cards.gift_card_number = @card_number
		AND transaction_master.transaction_ts BETWEEN @from AND @to
	) t
	ORDER BY t.transaction_ts ASC;

	UPDATE result
	SET balance = c.balance
	FROM @result result
	INNER JOIN	
	(
		SELECT
			p.id, 
			SUM(COALESCE(c.credit, 0) - COALESCE(c.debit, 0)) As balance
		FROM @result p
		LEFT JOIN @result AS c 
			ON (c.transaction_ts <= p.transaction_ts)
		GROUP BY p.id
	) AS c
	ON result.id = c.id;
        
	RETURN
END
GO





-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_gift_card_id_by_gift_card_number.sql --<--<--
IF OBJECT_ID('sales.get_gift_card_id_by_gift_card_number') IS NOT NULL
DROP FUNCTION sales.get_gift_card_id_by_gift_card_number;

GO

CREATE FUNCTION sales.get_gift_card_id_by_gift_card_number(@gift_card_number national character varying(100))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.gift_card_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.gift_card_number = @gift_card_number
	    AND sales.gift_cards.deleted = 0
    );
END;





GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_item_selling_price.sql --<--<--
IF OBJECT_ID('sales.get_item_selling_price') IS NOT NULL
DROP FUNCTION sales.get_item_selling_price;

GO

CREATE FUNCTION sales.get_item_selling_price(@office_id integer, @item_id integer, @customer_type_id integer, @price_type_id integer, @unit_id integer)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @price              numeric(30, 6);
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             numeric(30, 6);
    DECLARE @tax_rate           numeric(30, 6);
    DECLARE @includes_tax       bit;
    DECLARE @tax                numeric(30, 6);

    --Fist pick the catalog price which matches all these fields:
    --Item, Customer Type, Price Type, and Unit.
    --This is the most effective price.
    SELECT 
        @price              = item_selling_prices.price, 
        @costing_unit_id    = item_selling_prices.unit_id,
        @includes_tax       = item_selling_prices.includes_tax
    FROM sales.item_selling_prices
    WHERE item_selling_prices.item_id=@item_id
    AND item_selling_prices.customer_type_id=@customer_type_id
    AND item_selling_prices.price_type_id =@price_type_id
    AND item_selling_prices.unit_id = @unit_id
    AND sales.item_selling_prices.deleted = 0;

    IF(@costing_unit_id IS NULL)
    BEGIN
        --We do not have a selling price of this item for the unit supplied.
        --Let's see if this item has a price for other units.
        SELECT 
            @price              = item_selling_prices.price, 
            @costing_unit_id    = item_selling_prices.unit_id,
            @includes_tax       = item_selling_prices.includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=@item_id
        AND item_selling_prices.customer_type_id=@customer_type_id
        AND item_selling_prices.price_type_id =@price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    IF(@price IS NULL)
    BEGIN
        SELECT 
            @price              = item_selling_prices.price, 
            @costing_unit_id    = item_selling_prices.unit_id,
            @includes_tax       = item_selling_prices.includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=@item_id
        AND item_selling_prices.price_type_id =@price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    
    IF(@price IS NULL)
    BEGIN
        --This item does not have selling price defined in the catalog.
        --Therefore, getting the default selling price from the item definition.
        SELECT 
            @price              = selling_price, 
            @costing_unit_id    = unit_id,
            @includes_tax       = 0
        FROM inventory.items
        WHERE inventory.items.item_id = @item_id
        AND inventory.items.deleted = 0;
    END;

    IF(@includes_tax = 1)
    BEGIN
        SET @tax_rate = finance.get_sales_tax_rate(@office_id);
        SET @price = @price / ((100 + @tax_rate)/ 100);
    END;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    SET @factor = inventory.convert_unit(@unit_id, @costing_unit_id);

    RETURN @price * @factor;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_late_fee_id_by_late_fee_code.sql --<--<--
IF OBJECT_ID('sales.get_late_fee_id_by_late_fee_code') IS NOT NULL
DROP FUNCTION sales.get_late_fee_id_by_late_fee_code;

GO

CREATE FUNCTION sales.get_late_fee_id_by_late_fee_code(@late_fee_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.late_fee.late_fee_id
	    FROM sales.late_fee
	    WHERE sales.late_fee.late_fee_code = @late_fee_code
	    AND sales.late_fee.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_order_view.sql --<--<--
IF OBJECT_ID('sales.get_order_view') IS NOT NULL
DROP FUNCTION sales.get_order_view;

GO


CREATE FUNCTION sales.get_order_view
(
    @user_id                        integer,
    @office_id                      integer,
    @customer                       national character varying(500),
    @from                           date,
    @to                             date,
    @expected_from                  date,
    @expected_to                    date,
    @id                             bigint,
    @reference_number               national character varying(500),
    @internal_memo                  national character varying(500),
    @terms                          national character varying(500),
    @posted_by                      national character varying(500),
    @office                         national character varying(500)
)
RETURNS @result TABLE
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
    transaction_ts                  DATETIMEOFFSET
)
AS

BEGIN
    WITH office_cte(office_id) AS 
    (
        SELECT @office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    INSERT INTO @result
    SELECT 
        sales.orders.order_id,
        inventory.get_customer_name_by_customer_id(sales.orders.customer_id),
        sales.orders.value_date,
        sales.orders.expected_delivery_date,
        sales.orders.reference_number,
        sales.orders.terms,
        sales.orders.internal_memo,
        account.get_name_by_user_id(sales.orders.user_id) AS posted_by,
        core.get_office_name_by_office_id(office_id) AS office,
        sales.orders.transaction_timestamp
    FROM sales.orders
    WHERE 1 = 1
    AND sales.orders.value_date BETWEEN @from AND @to
    AND sales.orders.expected_delivery_date BETWEEN @expected_from AND @expected_to
    AND sales.orders.office_id IN (SELECT office_id FROM office_cte)
    AND (COALESCE(@id, 0) = 0 OR @id = sales.orders.order_id)
    AND COALESCE(LOWER(sales.orders.reference_number), '') LIKE '%' + LOWER(@reference_number) + '%' 
    AND COALESCE(LOWER(sales.orders.internal_memo), '') LIKE '%' + LOWER(@internal_memo) + '%' 
    AND COALESCE(LOWER(sales.orders.terms), '') LIKE '%' + LOWER(@terms) + '%' 
    AND LOWER(inventory.get_customer_name_by_customer_id(sales.orders.customer_id)) LIKE '%' + LOWER(@customer) + '%' 
    AND LOWER(account.get_name_by_user_id(sales.orders.user_id)) LIKE '%' + LOWER(@posted_by) + '%' 
    AND LOWER(core.get_office_name_by_office_id(sales.orders.office_id)) LIKE '%' + LOWER(@office) + '%' 
    AND sales.orders.deleted = 0;

    RETURN;
END;




--SELECT * FROM sales.get_order_view(1,1, '', '11/27/2010','11/27/2016','1-1-2000','1-1-2020', null,'','','','', '');


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_payable_account_for_gift_card.sql --<--<--
IF OBJECT_ID('sales.get_payable_account_for_gift_card') IS NOT NULL
DROP FUNCTION sales.get_payable_account_for_gift_card;

GO

CREATE FUNCTION sales.get_payable_account_for_gift_card(@gift_card_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.payable_account_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.gift_card_id= @gift_card_id
	    AND sales.gift_cards.deleted = 0
    );
END;





GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_payable_account_id_by_gift_card_id.sql --<--<--
IF OBJECT_ID('sales.get_payable_account_id_by_gift_card_id') IS NOT NULL
DROP FUNCTION sales.get_payable_account_id_by_gift_card_id;

GO

CREATE FUNCTION sales.get_payable_account_id_by_gift_card_id(@gift_card_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.payable_account_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.deleted = 0
	    AND sales.gift_cards.gift_card_id = @gift_card_id
   	);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_quotation_view.sql --<--<--
IF OBJECT_ID('sales.get_quotation_view') IS NOT NULL
DROP FUNCTION sales.get_quotation_view;

GO

CREATE FUNCTION sales.get_quotation_view
(
    @user_id                        integer,
    @office_id                      integer,
    @customer                       national character varying(500),
    @from                           date,
    @to                             date,
    @expected_from                  date,
    @expected_to                    date,
    @id                             bigint,
    @reference_number               national character varying(500),
    @internal_memo                  national character varying(500),
    @terms                          national character varying(500),
    @posted_by                      national character varying(500),
    @office                         national character varying(500)
)
RETURNS @result TABLE
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
    transaction_ts                  DATETIMEOFFSET
)
AS

BEGIN
    WITH office_cte(office_id) AS 
    (
        SELECT @office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    INSERT INTO @result
    SELECT 
        sales.quotations.quotation_id,
        inventory.get_customer_name_by_customer_id(sales.quotations.customer_id),
        sales.quotations.value_date,
        sales.quotations.expected_delivery_date,
        sales.quotations.reference_number,
        sales.quotations.terms,
        sales.quotations.internal_memo,
        account.get_name_by_user_id(sales.quotations.user_id) AS posted_by,
        core.get_office_name_by_office_id(office_id) AS office,
        sales.quotations.transaction_timestamp
    FROM sales.quotations
    WHERE 1 = 1
    AND sales.quotations.value_date BETWEEN @from AND @to
    AND sales.quotations.expected_delivery_date BETWEEN @expected_from AND @expected_to
    AND sales.quotations.office_id IN (SELECT office_id FROM office_cte)
    AND (COALESCE(@id, 0) = 0 OR @id = sales.quotations.quotation_id)
    AND COALESCE(LOWER(sales.quotations.reference_number), '') LIKE '%' + LOWER(@reference_number) + '%' 
    AND COALESCE(LOWER(sales.quotations.internal_memo), '') LIKE '%' + LOWER(@internal_memo) + '%' 
    AND COALESCE(LOWER(sales.quotations.terms), '') LIKE '%' + LOWER(@terms) + '%' 
    AND LOWER(inventory.get_customer_name_by_customer_id(sales.quotations.customer_id)) LIKE '%' + LOWER(@customer) + '%' 
    AND LOWER(account.get_name_by_user_id(sales.quotations.user_id)) LIKE '%' + LOWER(@posted_by) + '%' 
    AND LOWER(core.get_office_name_by_office_id(sales.quotations.office_id)) LIKE '%' + LOWER(@office) + '%' 
    AND sales.quotations.deleted = 0;

    RETURN;
END;




--SELECT * FROM sales.get_quotation_view(1,1,'','11/27/2010','11/27/2016','1-1-2000','1-1-2020', null,'','','','', '');


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_receivable_account_for_check_receipts.sql --<--<--
IF OBJECT_ID('sales.get_receivable_account_for_check_receipts') IS NOT NULL
DROP FUNCTION sales.get_receivable_account_for_check_receipts;

GO

CREATE FUNCTION sales.get_receivable_account_for_check_receipts(@store_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.stores.default_account_id_for_checks
	    FROM inventory.stores
	    WHERE inventory.stores.store_id = @store_id
	    AND inventory.stores.deleted = 0
	);
END;





GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_selling_price.sql --<--<--
IF OBJECT_ID('sales.get_selling_price') IS NOT NULL
DROP FUNCTION sales.get_selling_price;

GO

CREATE FUNCTION sales.get_selling_price(@office_id integer, @item_id integer, @customer_id integer, @price_type_id integer, @unit_id integer)
RETURNS numeric(30, 6)
AS
BEGIN	
    DECLARE @price              decimal(30, 6);
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             decimal(30, 6);
    DECLARE @tax_rate           decimal(30, 6);
    DECLARE @includes_tax       bit;
    DECLARE @tax                decimal(30, 6);
	DECLARE @customer_type_id	integer;

	SELECT
		@includes_tax	= inventory.items.selling_price_includes_tax
	FROM inventory.items
	WHERE inventory.items.item_id = @item_id;
	
	SELECT
		@price				= sales.customerwise_selling_prices.price,
		@costing_unit_id	= sales.customerwise_selling_prices.unit_id,
		@includes_tax		= sales.customerwise_selling_prices.is_taxable
	FROM sales.customerwise_selling_prices
	WHERE sales.customerwise_selling_prices.deleted = 0
	AND sales.customerwise_selling_prices.customer_id = @customer_id
	AND sales.customerwise_selling_prices.item_id = @item_id;

	IF(COALESCE(@price, 0) = 0)
	BEGIN
		RETURN sales.get_item_selling_price(@office_id, @item_id, inventory.get_customer_type_id_by_customer_id(@customer_id), @price_type_id, @unit_id);
	END;


    IF(@includes_tax = 1)
    BEGIN
        SET @tax_rate = finance.get_sales_tax_rate(@office_id);
        SET @price = @price / ((100 + @tax_rate)/ 100);
    END;

	--Get the unitary conversion factor if the requested unit does not match with the price defition.
    SET @factor = inventory.convert_unit(@unit_id, @costing_unit_id);

    RETURN @price * @factor;
END;

GO

--SELECT sales.get_selling_price(1,1,1,1,6);


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.get_top_selling_products_of_all_time.sql --<--<--
IF OBJECT_ID('sales.get_top_selling_products_of_all_time') IS NOT NULL
DROP FUNCTION sales.get_top_selling_products_of_all_time;

GO

CREATE FUNCTION sales.get_top_selling_products_of_all_time(@office_id int)
RETURNS @result TABLE
(
    id              integer,
    item_id         integer,
    item_code       text,
    item_name       text,
    total_sales     numeric(30, 6)
)
AS
BEGIN
    INSERT INTO @result(id, item_id, total_sales)
    SELECT ROW_NUMBER() OVER(ORDER BY sales_amount DESC), *
    FROM
    (
        SELECT
        TOP 10      
                inventory.verified_checkout_view.item_id, 
                SUM((price * quantity) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0)) AS sales_amount
        FROM inventory.verified_checkout_view
        WHERE inventory.verified_checkout_view.office_id = @office_id
        AND inventory.verified_checkout_view.book LIKE 'Sales%'
        GROUP BY inventory.verified_checkout_view.item_id
        ORDER BY 2 DESC
    ) t;

    UPDATE result
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name
    FROM @result AS result
    INNER JOIN inventory.items
    ON result.item_id = inventory.items.item_id;
    
    RETURN;
END

GO

--SELECT * FROM sales.get_top_selling_products_of_all_time(1);



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_cash_receipt.sql --<--<--
IF OBJECT_ID('sales.post_cash_receipt') IS NOT NULL
DROP PROCEDURE sales.post_cash_receipt;

GO

CREATE PROCEDURE sales.post_cash_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @cash_account_id                            integer,
    @cash_repository_id                         integer,
    @value_date                                 date,
    @book_date                                  date,
    @receivable                                 numeric(30, 6),
    @tender                                     numeric(30, 6),
    @change                                     numeric(30, 6),
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;

        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        IF(@tender < @receivable)
        BEGIN
            RAISERROR('The tendered amount must be greater than or equal to sales amount', 13, 1);
        END;
        
        SET @debit                                  = @receivable;
        SET @lc_debit                               = @receivable * @exchange_rate_debit;

        SET @credit                                 = @receivable * (@exchange_rate_debit/ @exchange_rate_credit);
        SET @lc_credit                              = @receivable * @exchange_rate_debit;

        INSERT INTO finance.transaction_master
        (
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
            finance.get_new_transaction_counter(@value_date), 
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book,
            @value_date,
            @book_date,
            @user_id,
            @login_id,
            @office_id,
            @cost_center_id,
            @reference_number,
            @statement_reference,
            @user_id,
            @cascading_tran_id;

        SET @transaction_master_id = SCOPE_IDENTITY();



        --Debit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @cash_account_id, @statement_reference, @cash_repository_id, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;

        --Credit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date,  book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
        
        
        INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, cash_repository_id, posted_date, tender, change, amount)
        SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @cash_repository_id, @value_date, @tender, @change, @receivable;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_check_receipt.sql --<--<--
IF OBJECT_ID('sales.post_check_receipt') IS NOT NULL
DROP PROCEDURE sales.post_check_receipt;

GO

CREATE PROCEDURE sales.post_check_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(@store_id)
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @value_date                                 date,
    @book_date                                  date,
    @check_amount                               numeric(30, 6),
    @check_bank_name                            national character varying(1000),
    @check_number                               national character varying(100),
    @check_date                                 date,
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @debit                                  = @check_amount;
        SET @lc_debit                               = @check_amount * @exchange_rate_debit;

        SET @credit                                 = @check_amount * (@exchange_rate_debit/ @exchange_rate_credit);
        SET @lc_credit                              = @check_amount * @exchange_rate_debit;
        
        INSERT INTO finance.transaction_master
        (
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
            finance.get_new_transaction_counter(@value_date), 
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book,
            @value_date,
            @book_date,
            @user_id,
            @login_id,
            @office_id,
            @cost_center_id,
            @reference_number,
            @statement_reference,
            @user_id,
            @cascading_tran_id;

        SET @transaction_master_id = SCOPE_IDENTITY();


        --Debit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @receivable_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        

        --Credit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
        
        
        INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, check_amount, check_bank_name, check_number, check_date, amount)
        SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @value_date, @check_amount, @check_bank_name, @check_number, @check_date, @check_amount;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


GO

--SELECT * FROM sales.post_check_receipt(1, 1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, '1-1-2020', '1-1-2020', 2000, '', '', '1-1-2020', null);


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_customer_receipt.sql --<--<--
IF OBJECT_ID('sales.post_customer_receipt') IS NOT NULL
DROP PROCEDURE sales.post_customer_receipt;

GO

CREATE PROCEDURE sales.post_customer_receipt
(
	@value_date									date,
	@book_date									date,
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer, 
    @currency_code                              national character varying(12),
    @cash_account_id                            integer,
    @amount                                     numeric(30, 6), 
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(128), 
    @cost_center_id                             integer,
    @cash_repository_id                         integer,
    @posted_date                                date,
    @bank_id									integer,
    @payment_card_id                            integer,
    @bank_instrument_code                       national character varying(128),
    @bank_tran_code                             national character varying(128),
    @transaction_master_id						bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @bank_account_id					integer = finance.get_account_id_by_bank_account_id(@bank_id);
    DECLARE @book                               national character varying(50);
    DECLARE @base_currency_code                 national character varying(12);
    DECLARE @local_currency_code                national character varying(12);
    DECLARE @customer_account_id                integer;
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @is_cash                            bit;
    DECLARE @is_merchant                        bit=0;
    DECLARE @merchant_rate                      numeric(30, 6)=0;
    DECLARE @customer_pays_fee                  bit=0;
    DECLARE @merchant_fee_accont_id             integer;
    DECLARE @merchant_fee_statement_reference   national character varying(2000);
    DECLARE @merchant_fee                       numeric(30, 6);
    DECLARE @merchant_fee_lc                    numeric(30, 6);
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

		IF(@cash_repository_id > 0)
		BEGIN
			IF(@posted_date IS NOT NULL OR @bank_id IS NOT NULL OR COALESCE(@bank_instrument_code, '') != '' OR COALESCE(@bank_tran_code, '') != '')
			BEGIN
				RAISERROR('Invalid bank transaction information provided.', 16, 1);
			END;

			SET @is_cash = 1;
		END;

		SET @book								= 'Sales Receipt';
    
		SET @customer_account_id				= inventory.get_account_id_by_customer_id(@customer_id);    
		SET @local_currency_code                = core.get_currency_code_by_office_id(@office_id);
		SET @base_currency_code                 = inventory.get_currency_code_by_customer_id(@customer_id);


		IF EXISTS
		(
			SELECT 1 FROM finance.bank_accounts
			WHERE is_merchant_account = 1
			AND bank_account_id = @bank_id
		)
		BEGIN
			SET @is_merchant = 1;
		END;

		SELECT 
			@merchant_rate						= rate,
			@customer_pays_fee					= customer_pays_fee,
			@merchant_fee_accont_id				=	account_id,
			@merchant_fee_statement_reference	= statement_reference
		FROM finance.merchant_fee_setup
		WHERE merchant_account_id = @bank_id
		AND payment_card_id = @payment_card_id;

		SET @merchant_rate		= COALESCE(@merchant_rate, 0);
		SET @customer_pays_fee  = COALESCE(@customer_pays_fee, 0);

		IF(@is_merchant = 1 AND COALESCE(@payment_card_id, 0) = 0)
		BEGIN
			RAISERROR('Invalid payment card information.', 16, 1);
		END;

		IF(@merchant_rate > 0 AND COALESCE(@merchant_fee_accont_id, 0) = 0)
		BEGIN
			RAISERROR('Could not find an account to post merchant fee expenses.', 16, 1);
		END;

		IF(@local_currency_code = @currency_code AND @exchange_rate_debit != 1)
		BEGIN
			RAISERROR('Invalid exchange rate.', 16, 1);
		END;

		IF(@base_currency_code = @currency_code AND @exchange_rate_credit != 1)
		BEGIN
			RAISERROR('Invalid exchange rate.', 16, 1);
		END ;
        
		SET @debit								= @amount;
		SET @lc_debit							= @amount * @exchange_rate_debit;

		SET @credit                             = @amount * (@exchange_rate_debit/ @exchange_rate_credit);
		SET @lc_credit                          = @amount * @exchange_rate_debit;
		SET @merchant_fee                       = (@debit * @merchant_rate) / 100;
		SET @merchant_fee_lc                    = (@lc_debit * @merchant_rate)/100;
    
		INSERT INTO finance.transaction_master
		(
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
			finance.get_new_transaction_counter(@value_date), 
			finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
			@book,
			@value_date,
			@book_date,
			@user_id,
			@login_id,
			@office_id,
			@cost_center_id,
			@reference_number,
			@statement_reference;

		SET @transaction_master_id = SCOPE_IDENTITY();
		--Debit
		IF(@is_cash = 1)
		BEGIN
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @cash_account_id, @statement_reference, @cash_repository_id, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;
		END
		ELSE
		BEGIN
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @bank_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        
		END;

		--Credit
		INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
		SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;


		IF(@is_merchant = 1 AND @merchant_rate > 0 AND @merchant_fee_accont_id > 0)
		BEGIN
			--Debit: Merchant Fee Expenses
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @merchant_fee_accont_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

			--Credit: Merchant A/C
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @bank_account_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

			IF(@customer_pays_fee = 1)
			BEGIN
				--Debit: Party Account Id
				INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
				SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @customer_account_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

				--Credit: Reverse Merchant Fee Expenses
				INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
				SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @merchant_fee_accont_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;
			END;
		END;
    
    
		INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, amount, er_debit, er_credit, cash_repository_id, posted_date, collected_on_bank_id, collected_bank_instrument_code, collected_bank_transaction_code)
		SELECT @transaction_master_id, @customer_id, @currency_code, @amount,  @exchange_rate_debit, @exchange_rate_credit, @cash_repository_id, @posted_date, @bank_id, @bank_instrument_code, @bank_tran_code;

		EXECUTE finance.auto_verify @transaction_master_id, @office_id;
		EXECUTE sales.settle_customer_due @customer_id, @office_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

 
-- EXECUTE sales.post_customer_receipt
 
--     1, --@user_id                                    integer, 
--     1, --@office_id                                  integer, 
--     1, --_login_id                                   bigint,
--     1, --_customer_id                                integer, 
--     'USD', --@currency_code                              national character varying(12), 
--     1,--    @cash_account_id                            integer,
--     100, --_amount                                     public.money_strict, 
--     1, --@exchange_rate_debit                        public.decimal_strict, 
--     1, --@exchange_rate_credit                       public.decimal_strict,
--     '', --_reference_number                           national character varying(24), 
--     '', --@statement_reference                        national character varying(128), 
--     1, --_cost_center_id                             integer,
--     1, --@cash_repository_id                         integer,
--     NULL, --_posted_date                                date,
--     NULL, --@bank_account_id                            bigint,
--     NULL, --_payment_card_id                            integer,
--     NULL, -- _bank_instrument_code                       national character varying(128),
--     NULL, -- _bank_tran_code                             national character varying(128),
--	 NULL
--;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_late_fee.sql --<--<--
IF OBJECT_ID('sales.post_late_fee') IS NOT NULL
DROP PROCEDURE sales.post_late_fee;

GO

CREATE PROCEDURE sales.post_late_fee(@user_id integer, @login_id bigint, @office_id integer, @value_date date)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @transaction_master_id          bigint;
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @book_name                      national character varying(100) = 'Late Fee';

    DECLARE @total_rows                     integer = 0;
    DECLARE @counter                        integer = 0;
    DECLARE @loop_transaction_master_id     bigint;
    DECLARE @loop_late_fee_name             national character varying(1000)
    DECLARE @loop_late_fee_account_id       integer;
    DECLARE @loop_customer_id               integer;
    DECLARE @loop_late_fee                  numeric(30, 6);
    DECLARE @loop_customer_account_id       integer;


    DECLARE @temp_late_fee TABLE
    (
        transaction_master_id               bigint,
        value_date                          date,
        payment_term_id                     integer,
        payment_term_code                   national character varying(50),
        payment_term_name                   national character varying(1000),        
        due_on_date                         bit,
        due_days                            integer,
        due_frequency_id                    integer,
        grace_period                        integer,
        late_fee_id                         integer,
        late_fee_posting_frequency_id       integer,
        late_fee_code                       national character varying(50),
        late_fee_name                       national character varying(1000),
        is_flat_amount                      bit,
        rate                                numeric(30, 6),
        due_amount                          numeric(30, 6),
        late_fee                            numeric(30, 6),
        customer_id                         integer,
        customer_account_id                 integer,
        late_fee_account_id                 integer,
        due_date                            date
    ) ;

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
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
            AND  finance.transaction_master.book IN('Sales.Delivery', 'Sales.Direct')
            AND  sales.sales.is_credit = 1 AND  sales.sales.credit_settled = 0
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
            CASE WHEN unpaid_invoices.due_on_date = 1
            THEN DATEADD(day, unpaid_invoices.due_days + unpaid_invoices.grace_period, unpaid_invoices.value_date)
            ELSE DATEADD(day, unpaid_invoices.grace_period, finance.get_frequency_end_date(unpaid_invoices.due_frequency_id, unpaid_invoices.value_date)) END as due_date
            FROM unpaid_invoices
        )


        INSERT INTO @temp_late_fee
        SELECT * FROM unpaid_invoices_details
        WHERE unpaid_invoices_details.due_date <= @value_date;


        UPDATE @temp_late_fee
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
            WHERE  inventory.checkouts.transaction_master_id = transaction_master_id
        ) WHERE is_flat_amount = 0;

        UPDATE @temp_late_fee
        SET late_fee = rate
        WHERE is_flat_amount = 1;

        UPDATE @temp_late_fee
        SET late_fee = due_amount * rate / 100
        WHERE is_flat_amount = 0;

        SET @default_currency_code                  =  core.get_currency_code_by_office_id(@office_id);

        DELETE FROM @temp_late_fee
        WHERE late_fee <= 0
        AND customer_account_id IS NULL
        AND late_fee_account_id IS NULL;


        SELECT @total_rows = MAX(transaction_master_id) FROM @temp_late_fee;

        WHILE @counter <= @total_rows
        BEGIN
            SELECT TOP 1 
                @loop_transaction_master_id = transaction_master_id,
                @loop_late_fee_name = late_fee_name,
                @loop_late_fee_account_id = late_fee_account_id,
                @loop_customer_id = customer_id,
                @loop_late_fee = late_fee,
                @loop_customer_account_id = customer_account_id
            FROM @temp_late_fee
            WHERE transaction_master_id >= @counter
            ORDER BY transaction_master_id;

            IF(@loop_transaction_master_id IS NOT NULL)
            BEGIN
                SET @counter = @loop_transaction_master_id + 1;        
            END
            ELSE
            BEGIN
                BREAK;
            END;

            SET @tran_counter           = finance.get_new_transaction_counter(@value_date);
            SET @transaction_code       = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

            INSERT INTO  finance.transaction_master
            (
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
                @tran_counter, 
                @transaction_code, 
                @book_name, 
                @value_date, 
                @user_id, 
                @office_id,             
                CAST(@loop_transaction_master_id AS varchar(100)) AS reference_number,
                @loop_late_fee_name AS statement_reference,
                1,
                @user_id,
                'Automatically verified by workflow.';

            SET @transaction_master_id = SCOPE_IDENTITY();


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
                @transaction_master_id,
                @value_date,
                'Cr',
                @loop_late_fee_account_id,
                @loop_late_fee_name + ' (' + core.get_customer_code_by_customer_id(@loop_customer_id) + ')',
                @default_currency_code, 
                @loop_late_fee, 
                1 AS exchange_rate,
                @default_currency_code,
                @loop_late_fee
            UNION ALL
            SELECT
                @transaction_master_id,
                @value_date,
                'Dr',
                @loop_customer_account_id,
                @loop_late_fee_name,
                @default_currency_code, 
                @loop_late_fee, 
                1 AS exchange_rate,
                @default_currency_code,
                @loop_late_fee;

            INSERT INTO  sales.late_fee_postings(transaction_master_id, customer_id, value_date, late_fee_tran_id, amount)
            SELECT @loop_transaction_master_id, @loop_customer_id, @value_date, @transaction_master_id, @loop_late_fee;
        END;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;




--SELECT * FROM  sales.post_late_fee(2, 5, 2,  finance.get_value_date(2));

GO

EXECUTE finance.create_routine 'POST-LF', ' sales.post_late_fee', 2500;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_receipt.sql --<--<--
IF OBJECT_ID('sales.post_receipt') IS NOT NULL
DROP PROCEDURE sales.post_receipt;

GO

CREATE PROCEDURE sales.post_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    
    @customer_id                                integer,
    @currency_code                              national character varying(12), 
    @exchange_rate_debit                        numeric(30, 6), 

    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 

    @cost_center_id                             integer,
    @cash_account_id                            integer,
    @cash_repository_id                         integer,

    @value_date                                 date,
    @book_date                                  date,
    @receipt_amount                             numeric(30, 6),

    @tender                                     numeric(30, 6),
    @change                                     numeric(30, 6),
    @check_amount                               numeric(30, 6),

    @check_bank_name                            national character varying(1000),
    @check_number                               national character varying(100),
    @check_date                                 date,

    @gift_card_number                           national character varying(100),
    @store_id                                   integer,
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50);
    DECLARE @base_currency_code                 national character varying(12);
    DECLARE @local_currency_code                national character varying(12);
    DECLARE @customer_account_id                integer;
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @is_cash                            bit;
    DECLARE @gift_card_id                       integer;
    DECLARE @receivable_account_id              integer;
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        IF(@cash_repository_id > 0 AND @cash_account_id > 0)
        BEGIN
            SET @is_cash                            = 1;
        END;

        SET @receivable_account_id                  = sales.get_receivable_account_for_check_receipts(@store_id);
        SET @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
        SET @customer_account_id                    = inventory.get_account_id_by_customer_id(@customer_id);    
        SET @local_currency_code                    = core.get_currency_code_by_office_id(@office_id);
        SET @base_currency_code                     = inventory.get_currency_code_by_customer_id(@customer_id);


        IF(@local_currency_code = @currency_code AND @exchange_rate_debit != 1)
        BEGIN
            RAISERROR('Invalid exchange rate.', 13, 1);
        END;

        IF(@base_currency_code = @currency_code AND @exchange_rate_credit != 1)
        BEGIN
            RAISERROR('Invalid exchange rate.', 13, 1);
        END;

        
        IF(@tender >= @receipt_amount)
        BEGIN
            EXECUTE sales.post_cash_receipt @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @cash_account_id, @cash_repository_id, @value_date, @book_date, @receipt_amount, @tender, @change, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE IF(@check_amount >= @receipt_amount)
        BEGIN
            EXECUTE sales.post_check_receipt @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @receivable_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @value_date, @book_date, @check_amount, @check_bank_name, @check_number, @check_date, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE IF(@gift_card_id > 0)
        BEGIN
            EXECUTE sales.post_receipt_by_gift_card @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @value_date, @book_date, @gift_card_id, @gift_card_number, @receipt_amount, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE
        BEGIN
            RAISERROR('Cannot post receipt. Please enter the tender amount.', 13, 1);
        END;

        
        EXECUTE finance.auto_verify @transaction_master_id, @office_id;
        EXECUTE sales.settle_customer_due @customer_id, @office_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


GO



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_receipt_by_gift_card.sql --<--<--
IF OBJECT_ID('sales.post_receipt_by_gift_card') IS NOT NULL
DROP PROCEDURE sales.post_receipt_by_gift_card;

GO

CREATE PROCEDURE sales.post_receipt_by_gift_card
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @value_date                                 date,
    @book_date                                  date,
    @gift_card_id                               integer,
    @gift_card_number                           national character varying(100),
    @amount                                     numeric(30, 6),
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @is_cash                            bit;
    DECLARE @gift_card_payable_account_id       integer;
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @gift_card_payable_account_id           = sales.get_payable_account_for_gift_card(@gift_card_id);
        SET @debit                                  = @amount;
        SET @lc_debit                               = @amount * @exchange_rate_debit;

        SET @credit                                 = @amount * (@exchange_rate_debit/ @exchange_rate_credit);
        SET @lc_credit                              = @amount * @exchange_rate_debit;
        
        INSERT INTO finance.transaction_master
        (
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
            finance.get_new_transaction_counter(@value_date), 
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book,
            @value_date,
            @book_date,
            @user_id,
            @login_id,
            @office_id,
            @cost_center_id,
            @reference_number,
            @statement_reference,
            @user_id,
            @cascading_tran_id;


        SET @transaction_master_id = SCOPE_IDENTITY();

        --Debit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @gift_card_payable_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        

        --Credit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
        
        
        INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, gift_card_number, amount)
        SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @value_date, @gift_card_number, @amount;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_return.sql --<--<--
IF OBJECT_ID('sales.post_return') IS NOT NULL
DROP PROCEDURE sales.post_return;

GO

CREATE PROCEDURE sales.post_return
(
    @transaction_master_id          bigint,
    @office_id                      integer,
    @user_id                        integer,
    @login_id                       bigint,
    @value_date                     date,
    @book_date                      date,
    @store_id                       integer,
    @counter_id                     integer,
    @customer_id                    integer,
    @price_type_id                  integer,
    @reference_number               national character varying(24),
    @statement_reference            national character varying(2000),
    @details                        sales.sales_detail_type READONLY,
	@shipper_id						integer,
	@discount						numeric(30, 6),
    @tran_master_id                 bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @reversal_tran_id		bigint;
	DECLARE @new_tran_id			bigint;
    DECLARE @book_name              national character varying(50) = 'Sales Return';
    DECLARE @cost_center_id         bigint;
    DECLARE @tran_counter           integer;
    DECLARE @tran_code              national character varying(50);
    DECLARE @checkout_id            bigint;
    DECLARE @grand_total            numeric(30, 6);
    DECLARE @discount_total         numeric(30, 6);
    DECLARE @is_credit              bit;
    DECLARE @default_currency_code  national character varying(12);
    DECLARE @cost_of_goods_sold     numeric(30, 6);
    DECLARE @ck_id                  bigint;
    DECLARE @sales_id               bigint;
    DECLARE @tax_total              numeric(30, 6);
    DECLARE @tax_account_id         integer;
	DECLARE @fiscal_year_code		national character varying(12);
    DECLARE @can_post_transaction   bit;
    DECLARE @error_message          national character varying(MAX);
	DECLARE @original_checkout_id	bigint;
	DECLARE @original_customer_id	integer;
	DECLARE @difference				sales.sales_detail_type;
	DECLARE @validate				bit;

	SELECT @validate = validate_returns 
	FROM inventory.inventory_setup
	WHERE office_id = @office_id;

	IF(COALESCE(@transaction_master_id, 0) = 0 AND @validate = 0)
	BEGIN
		EXECUTE sales.post_return_without_validation
			@office_id                      ,
			@user_id                        ,
			@login_id                       ,
			@value_date                     ,
			@book_date                      ,
			@store_id                       ,
			@counter_id                     ,
			@customer_id                    ,
			@price_type_id                  ,
			@reference_number               ,
			@statement_reference            ,
			@details                        ,
			@shipper_id						,
			@discount						,
			@tran_master_id                 OUTPUT;
		
		RETURN;
	END;

	SELECT 
		@original_customer_id = sales.sales.customer_id,
		@original_checkout_id = sales.sales.checkout_id
	FROM sales.sales
	INNER JOIN finance.transaction_master
	ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
	AND finance.transaction_master.verification_status_id > 0
	AND finance.transaction_master.transaction_master_id = @transaction_master_id;

	DECLARE @new_checkout_items TABLE
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
	);
		
    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
    	    
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);

		
		IF(@original_customer_id IS NULL)
		BEGIN
			RAISERROR('Invalid transaction.', 16, 1);
		END;

		IF(@original_customer_id != @customer_id)
		BEGIN
			RAISERROR('This customer is not associated with the sales you are trying to return.', 16, 1);
		END;

		DECLARE @is_valid_transaction	bit;
		SELECT
			@is_valid_transaction	=	is_valid,
			@error_message			=	"error_message"
		FROM sales.validate_items_for_return(@transaction_master_id, @details);

        IF(@is_valid_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 16, 1);
            RETURN;
        END;

        SET @default_currency_code      = core.get_currency_code_by_office_id(@office_id);
        SET @tran_counter               = finance.get_new_transaction_counter(@value_date);
        SET @tran_code                  = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

        SELECT @sales_id = sales.sales.sales_id 
        FROM sales.sales
        WHERE sales.sales.transaction_master_id = @transaction_master_id;




		--Returned items are subtracted
		INSERT INTO @new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
		SELECT store_id, item_id, quantity *-1, unit_id, price *-1, ROUND(discount_rate, 2), shipping_charge *-1
		FROM @details;
	
		--Original items are added
		INSERT INTO @new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
		SELECT 
			inventory.checkout_details.store_id, 
			inventory.checkout_details.item_id,
			inventory.checkout_details.quantity,
			inventory.checkout_details.unit_id,
			inventory.checkout_details.price,
			ROUND(inventory.checkout_details.discount_rate, 2),
			inventory.checkout_details.shipping_charge
		FROM inventory.checkout_details
		WHERE checkout_id = @original_checkout_id;

		UPDATE @new_checkout_items 
		SET
			base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
			base_unit_id                    = inventory.get_root_unit_id(unit_id),
			discount                        = ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2);
	

		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT unit_id) 
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT unit_id) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the unit of measure provided during sales.', 16, 1);
		END;
	
		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT ABS(price))
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT ABS(price)) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the price provided during sales.', 16, 1);
		END;
	
		
	
		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT store_id) 
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT store_id) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the store provided during sales.', 16, 1);
		END;


		INSERT INTO @difference(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge)
		SELECT store_id, 'Cr', item_id, SUM(quantity), unit_id, SUM(price), SUM(discount), SUM(shipping_charge)
		FROM @new_checkout_items
		GROUP BY store_id, item_id, unit_id;
			
		DELETE FROM @difference
		WHERE quantity = 0;

		--> REVERSE THE ORIGINAL TRANSACTION
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
		SELECT @tran_counter, @tran_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;

		SET @reversal_tran_id = SCOPE_IDENTITY();

		INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
		SELECT 
			@reversal_tran_id, 
			office_id, 
			value_date, 
			book_date, 
			CASE WHEN tran_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
			account_id, 
			@statement_reference, 
			currency_code, 
			amount_in_currency, 
			er, 
			local_currency_code, 
			amount_in_local_currency
		FROM finance.transaction_details
		WHERE finance.transaction_details.transaction_master_id = @transaction_master_id;

		IF EXISTS(SELECT * FROM @difference)
		BEGIN
			--> ADD A NEW SALES INVOICE
			EXECUTE sales.post_sales
				@office_id,
				@user_id,
				@login_id,
				@counter_id,
				@value_date,
				@book_date,
				@cost_center_id,
				@reference_number,
				@statement_reference,
				NULL, --@tender,
				NULL, --@change,
				NULL, --@payment_term_id,
				NULL, --@check_amount,
				NULL, --@check_bank_name,
				NULL, --@check_number,
				NULL, --@check_date,
				NULL, --@gift_card_number,
				@customer_id,
				@price_type_id,
				@shipper_id,
				@store_id,
				NULL, --@coupon_code,
				1, --@is_flat_discount,
				@discount,
				@difference,
				NULL, --@sales_quotation_id,
				NULL, --@sales_order_id,
				NULL, --@serial_number_ids
				@new_tran_id  OUTPUT,
				@book_name;
		END;
		ELSE
		BEGIN
			SET @tran_counter               = finance.get_new_transaction_counter(@value_date);
			SET @tran_code                  = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

			INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
			SELECT @tran_counter, @tran_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;

			SET @new_tran_id = SCOPE_IDENTITY();
		END;

		INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, office_id, posted_by, discount, taxable_total, tax_rate, tax, nontaxable_total) 
		SELECT @book_name, @value_date, @book_date, @new_tran_id, office_id, @user_id, discount, taxable_total, tax_rate, tax, nontaxable_total
		FROM inventory.checkouts
		WHERE inventory.checkouts.checkout_id = @original_checkout_id;

		SET @checkout_id = SCOPE_IDENTITY();

        INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount)
		SELECT @value_date, @book_date, @checkout_id, 
		CASE WHEN transaction_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
		store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount
		FROM inventory.checkout_details
		WHERE inventory.checkout_details.checkout_id = @original_checkout_id;

		INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
		SELECT @sales_id, @checkout_id, @transaction_master_id, @new_tran_id, @counter_id, @customer_id, @price_type_id;

		SET @tran_master_id = @new_tran_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO




--DECLARE @transaction_master_id          bigint = 369;
--DECLARE @office_id                      integer = (SELECT TOP 1 office_id FROM core.offices);
--DECLARE @user_id                        integer = (SELECT TOP 1 user_id FROM account.users);
--DECLARE @login_id                       bigint = (SELECT TOP 1 login_id FROM account.logins WHERE user_id = @user_id);
--DECLARE @value_date                     date = finance.get_value_date(@office_id);
--DECLARE @book_date                      date = finance.get_value_date(@office_id);
--DECLARE @store_id                       integer = (SELECT TOP 1 store_id FROM inventory.stores WHERE store_name='Cold Room RM');
--DECLARE @counter_id                     integer = (SELECT TOP 1 counter_id FROM inventory.counters WHERE counter_name = 'Counter 2');
--DECLARE @customer_id                    integer = (SELECT customer_id FROM inventory.customers WHERE customer_name = 'Ajima Mart');
--DECLARE @price_type_id                  integer = (SELECT TOP 1 price_type_id FROM sales.price_types);
--DECLARE @reference_number               national character varying(24) = 'N/A';
--DECLARE @statement_reference            national character varying(2000) = 'Test';
--DECLARE @details                        sales.sales_detail_type;
--DECLARE @tran_master_id                 bigint;

--INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge, is_taxed)
--SELECT @store_id, 'Cr', 1, 1, 1, 2320, 62.84, 0, 1;


--EXECUTE sales.post_return
--    @transaction_master_id          ,
--    @office_id                      ,
--    @user_id                        ,
--    @login_id                       ,
--    @value_date                     ,
--    @book_date                      ,
--    @store_id                       ,
--    @counter_id                     ,
--    @customer_id                    ,
--    @price_type_id                  ,
--    @reference_number               ,
--    @statement_reference            ,
--    @details                        ,
--	1,
--	0,
--    @tran_master_id                 OUTPUT;













-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_return_without_validation.sql --<--<--
IF OBJECT_ID('sales.post_return_without_validation') IS NOT NULL
DROP PROCEDURE sales.post_return_without_validation;

GO

CREATE PROCEDURE sales.post_return_without_validation
(
    @office_id                      integer,
    @user_id                        integer,
    @login_id                       bigint,
    @value_date                     date,
    @book_date                      date,
    @store_id                       integer,
    @counter_id                     integer,
    @customer_id                    integer,
    @price_type_id                  integer,
    @reference_number               national character varying(24),
    @statement_reference            national character varying(2000),
    @details                        sales.sales_detail_type READONLY,
	@shipper_id						integer,
	@discount						numeric(30, 6),
    @tran_master_id                 bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book_name						national character varying(50) = 'Sales Return';
    DECLARE @cost_center_id					bigint;
    DECLARE @tran_counter					integer;
    DECLARE @tran_code						national character varying(50);
    DECLARE @checkout_id					bigint;
    DECLARE @grand_total					numeric(30, 6);
    DECLARE @discount_total					numeric(30, 6);
    DECLARE @default_currency_code			national character varying(12);
    DECLARE @tax_total						numeric(30, 6);
    DECLARE @tax_account_id					integer;
    DECLARE @can_post_transaction			bit;
    DECLARE @error_message					national character varying(MAX);
	DECLARE @sales_tax_rate					numeric(30, 6);
	DECLARE @taxable_total					numeric(30, 6);
	DECLARE @nontaxable_total				numeric(30, 6);
    DECLARE @invoice_discount				numeric(30, 6);
    DECLARE @shipping_charge                numeric(30, 6);
    DECLARE @payable						numeric(30, 6);
    DECLARE @transaction_code               national character varying(50);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
	DECLARE @transaction_master_id			bigint;
    DECLARE @cost_of_goods                  numeric(30, 6);

    DECLARE @checkout_details TABLE
    (
        id                                  integer IDENTITY PRIMARY KEY,
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
		is_taxable_item						bit,
		is_taxed							bit,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6) NOT NULL DEFAULT(0),
        sales_account_id					integer, 
        sales_discount_account_id			integer, 
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    );

    DECLARE @temp_transaction_details TABLE
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
    );

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
    	    
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @tax_account_id                 = finance.get_sales_tax_account_id_by_office_id(@office_id);

        IF(COALESCE(@customer_id, 0) = 0)
        BEGIN
            RAISERROR('Invalid customer', 13, 1);
        END;
        


		SELECT @sales_tax_rate = finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.deleted = 0
		AND finance.tax_setups.office_id = @office_id;

        INSERT INTO @checkout_details(store_id, transaction_type, item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, is_taxed)
        SELECT store_id, 'Dr', item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, COALESCE(is_taxed, 1)
        FROM @details;

        UPDATE @checkout_details 
        SET
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id),
            sales_account_id				= inventory.get_sales_account_id(item_id),
            sales_discount_account_id		= inventory.get_sales_discount_account_id(item_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id),
            cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);
        
		UPDATE @checkout_details
		SET
            discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
		WHERE COALESCE(discount, 0) = 0;

		UPDATE @checkout_details
		SET
            discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
		WHERE COALESCE(discount_rate, 0) = 0;


		UPDATE @checkout_details 
		SET 
			is_taxable_item = inventory.items.is_taxable_item
		FROM @checkout_details AS checkout_details
		INNER JOIN inventory.items
		ON inventory.items.item_id = checkout_details.item_id;

		UPDATE @checkout_details
		SET is_taxed = 0
		WHERE is_taxable_item = 0;

		UPDATE @checkout_details
		SET amount = (COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0);

		IF EXISTS
		(
			SELECT 1
			FROM @checkout_details
			WHERE amount < 0
		)
		BEGIN
			RAISERROR('A line amount cannot be less than zero.', 16, 1);
		END;

        IF EXISTS
        (
            SELECT TOP 1 0 FROM @checkout_details AS details
            WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
        )
        BEGIN
            RAISERROR('Item/unit mismatch.', 13, 1);
        END;

		SELECT 
			@taxable_total		= COALESCE(SUM(CASE WHEN is_taxed = 1 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
			@nontaxable_total	= COALESCE(SUM(CASE WHEN is_taxed = 0 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
		FROM @checkout_details;

		IF(@invoice_discount > @taxable_total)
		BEGIN
			RAISERROR('The invoice discount cannot be greater than total taxable amount.', 16, 1);
		END;

        SELECT @discount_total				= SUM(COALESCE(discount, 0)) FROM @checkout_details;

        SELECT @shipping_charge				= SUM(COALESCE(shipping_charge, 0)) FROM @checkout_details;
        SELECT @tax_total					= ROUND((COALESCE(@taxable_total, 0) - COALESCE(@invoice_discount, 0)) * (@sales_tax_rate / 100), 2);
        SELECT @grand_total					= COALESCE(@taxable_total, 0) + COALESCE(@nontaxable_total, 0) + COALESCE(@tax_total, 0) - COALESCE(@discount_total, 0)  - COALESCE(@invoice_discount, 0);
        SET @payable						= @grand_total;

        SET @default_currency_code          = core.get_currency_code_by_office_id(@office_id);
        SET @tran_counter                   = finance.get_new_transaction_counter(@value_date);
        SET @transaction_code               = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);









        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
        FROM @checkout_details
        GROUP BY sales_account_id;

        IF(@is_periodic = 0)
        BEGIN
            --Perpetutal Inventory Accounting System
            UPDATE @checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);

            SELECT @cost_of_goods = SUM(cost_of_goods_sold)
            FROM @checkout_details;


            IF(@cost_of_goods > 0)
            BEGIN
                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Cr', cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY cost_of_goods_sold_account_id;

                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Dr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY inventory_account_id;
            END;
        END;

        IF(COALESCE(@tax_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
        END;

        IF(COALESCE(@shipping_charge, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', inventory.get_account_id_by_shipper_id(@shipper_id), @statement_reference, @default_currency_code, @shipping_charge, 1, @default_currency_code, @shipping_charge;                
        END;


        IF(COALESCE(@discount_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
            FROM @checkout_details
            GROUP BY sales_discount_account_id
            HAVING SUM(COALESCE(discount, 0)) > 0;
        END;


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @payable, 1, @default_currency_code, @payable;
        
		IF
		(
			SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
			FROM @temp_transaction_details
		) != 0
		BEGIN
			SELECT finance.get_account_name_by_account_id(account_id), * FROM @temp_transaction_details ORDER BY tran_type;
			RAISERROR('Could not balance the Journal Entry. Nothing was saved.', 16, 1);		
		END;
		




















        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
        SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        SET @transaction_master_id = SCOPE_IDENTITY();
        
        INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @value_date, @book_date, @office_id, @transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;


        INSERT INTO inventory.checkouts(value_date, book_date, transaction_master_id, transaction_book, posted_by, shipper_id, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
        SELECT @value_date, @book_date, @transaction_master_id, @book_name, @user_id, @shipper_id, @office_id, @invoice_discount, @taxable_total, @sales_tax_rate, @tax_total, @nontaxable_total;
        SET @checkout_id                = SCOPE_IDENTITY();


        INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity)
        SELECT @checkout_id, @value_date, @book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity
        FROM @checkout_details;
        

        EXECUTE finance.auto_verify @transaction_master_id, @office_id;


		INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
		SELECT NULL, @checkout_id, NULL, @transaction_master_id, @counter_id, @customer_id, @price_type_id;

		SET @tran_master_id = @transaction_master_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO




--DECLARE @transaction_master_id          bigint = 369;
--DECLARE @office_id                      integer = (SELECT TOP 1 office_id FROM core.offices);
--DECLARE @user_id                        integer = (SELECT TOP 1 user_id FROM account.users);
--DECLARE @login_id                       bigint = (SELECT TOP 1 login_id FROM account.logins WHERE user_id = @user_id);
--DECLARE @value_date                     date = finance.get_value_date(@office_id);
--DECLARE @book_date                      date = finance.get_value_date(@office_id);
--DECLARE @store_id                       integer = (SELECT TOP 1 store_id FROM inventory.stores);
--DECLARE @counter_id                     integer = (SELECT TOP 1 counter_id FROM inventory.counters);
--DECLARE @customer_id                    integer = (SELECT TOP 1 customer_id FROM inventory.customers);
--DECLARE @price_type_id                  integer = (SELECT TOP 1 price_type_id FROM sales.price_types);
--DECLARE @reference_number               national character varying(24) = 'N/A';
--DECLARE @statement_reference            national character varying(2000) = 'Test';
--DECLARE @details                        sales.sales_detail_type;
--DECLARE @tran_master_id                 bigint;

--INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge, is_taxed)
--SELECT @store_id, 'Cr', 1, 1, 1, 2320, 62.84, 0, 1;


--EXECUTE sales.post_return_without_validation
--    @office_id                      ,
--    @user_id                        ,
--    @login_id                       ,
--    @value_date                     ,
--    @book_date                      ,
--    @store_id                       ,
--    @counter_id                     ,
--    @customer_id                    ,
--    @price_type_id                  ,
--    @reference_number               ,
--    @statement_reference            ,
--    @details                        ,
--	1,
--	0,
--    @tran_master_id                 OUTPUT;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.post_sales.sql --<--<--
IF OBJECT_ID('sales.post_sales') IS NOT NULL
DROP PROCEDURE sales.post_sales;

GO

CREATE PROCEDURE sales.post_sales
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @counter_id                             integer,
    @value_date                             date,
    @book_date                              date,
    @cost_center_id                         integer,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @tender                                 numeric(30, 6),
    @change                                 numeric(30, 6),
    @payment_term_id                        integer,
    @check_amount                           numeric(30, 6),
    @check_bank_name                        national character varying(1000),
    @check_number                           national character varying(100),
    @check_date                             date,
    @gift_card_number                       national character varying(100),
    @customer_id                            integer,
    @price_type_id                          integer,
    @shipper_id                             integer,
    @store_id                               integer,
    @coupon_code                            national character varying(100),
    @is_flat_discount                       bit,
    @discount                               numeric(30, 6),
    @details                                sales.sales_detail_type READONLY,
    @sales_quotation_id                     bigint,
    @sales_order_id                         bigint,
	@serial_number_ids						national character varying(max),
    @transaction_master_id                  bigint OUTPUT,
	@book_name								national character varying(48) = 'Sales Entry'
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @checkout_id                    bigint;
    DECLARE @grand_total                    numeric(30, 6);
    DECLARE @discount_total                 numeric(30, 6);
    DECLARE @receivable                     numeric(30, 6);
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @cost_of_goods                  numeric(30, 6);
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @tax_total                      numeric(30, 6);
    DECLARE @shipping_charge                numeric(30, 6);
    DECLARE @cash_repository_id             integer;
    DECLARE @cash_account_id                integer;
    DECLARE @is_cash                        bit = 0;
    DECLARE @is_credit                      bit = 0;
    DECLARE @gift_card_id                   integer;
    DECLARE @gift_card_balance              numeric(30, 6);
    DECLARE @coupon_id                      integer;
    DECLARE @fiscal_year_code               national character varying(12);
    DECLARE @invoice_number                 bigint;
    DECLARE @tax_account_id                 integer;
    DECLARE @receipt_transaction_master_id  bigint;

    DECLARE @total_rows                     integer = 0;
    DECLARE @counter                        integer = 0;

    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);

	DECLARE @sales_tax_rate					numeric(30, 6);
	DECLARE @taxable_total					numeric(30, 6);
	DECLARE @nontaxable_total				numeric(30, 6);
    DECLARE @coupon_discount                numeric(30, 6); 

    DECLARE @checkout_details TABLE
    (
        id                                  integer IDENTITY PRIMARY KEY,
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
		is_taxed							bit,
		is_taxable_item						bit,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6),
        sales_account_id                    integer,
        sales_discount_account_id           integer,
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    );

    DECLARE @item_quantities TABLE
    (
        item_id                             integer,
		unit_id								integer,
        base_unit_id                        integer,
        store_id                            integer,
		quantity							numeric(30, 6),
        total_sales                         numeric(30, 6),
        in_stock                            numeric(30, 6),
        maintain_inventory                  bit
    );

    DECLARE @temp_transaction_details TABLE
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
    ) ;

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);
        SET @default_currency_code                  = core.get_currency_code_by_office_id(@office_id);
        SET @cash_account_id                        = inventory.get_cash_account_id_by_store_id(@store_id);
        SET @cash_repository_id                     = inventory.get_cash_repository_id_by_store_id(@store_id);
        SET @is_cash                                = finance.is_cash_account_id(@cash_account_id);    

        SET @coupon_id                              = sales.get_active_coupon_id_by_coupon_code(@coupon_code);
        SET @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
        SET @gift_card_balance                      = sales.get_gift_card_balance(@gift_card_id, @value_date);


        SELECT TOP 1 @fiscal_year_code = finance.fiscal_year.fiscal_year_code
        FROM finance.fiscal_year
        WHERE @value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on;

        IF(COALESCE(@customer_id, 0) = 0)
        BEGIN
            RAISERROR('Please select a customer.', 13, 1);
        END;

        IF(COALESCE(@coupon_code, '') != '' AND COALESCE(@discount, 0) > 0)
        BEGIN
            RAISERROR('Please do not specify discount rate when you mention coupon code.', 13, 1);
        END;
        --TODO: VALIDATE COUPON CODE AND POST DISCOUNT

        IF(COALESCE(@payment_term_id, 0) > 0)
        BEGIN
            SET @is_credit                          = 1;
        END;

        IF(@is_credit = 0 AND @is_cash = 0)
        BEGIN
            RAISERROR('Cannot post sales. Invalid cash account mapping on store.', 13, 1);
        END;

       
        IF(@is_cash = 0)
        BEGIN
            SET @cash_repository_id                 = NULL;
        END;

		SELECT @sales_tax_rate = finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.deleted = 0
		AND finance.tax_setups.office_id = @office_id;

        INSERT INTO @checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
        SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
        FROM @details;


        UPDATE @checkout_details 
        SET
            tran_type                       = 'Cr',
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id);

		UPDATE @checkout_details
		SET
            discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
		WHERE COALESCE(discount, 0) = 0;

		UPDATE @checkout_details
		SET
            discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
		WHERE COALESCE(discount_rate, 0) = 0;


        UPDATE @checkout_details
        SET
            sales_account_id                = inventory.get_sales_account_id(item_id),
            sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id),
            cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

		UPDATE @checkout_details 
		SET is_taxable_item = is_taxed;

		UPDATE @checkout_details
		SET amount = (COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0);


		IF EXISTS
		(
			SELECT 1
			FROM @checkout_details
			WHERE amount < 0
		)
		BEGIN
			RAISERROR('A line amount cannot be less than zero.', 16, 1);
		END;

        INSERT INTO @item_quantities(item_id, base_unit_id, unit_id, store_id, quantity, total_sales)
        SELECT item_id, base_unit_id, unit_id, store_id, SUM(quantity), SUM(base_quantity)
        FROM @checkout_details
        GROUP BY item_id, base_unit_id, unit_id, store_id;

        UPDATE @item_quantities
        SET maintain_inventory = inventory.items.maintain_inventory
        FROM @item_quantities AS item_quantities 
        INNER JOIN inventory.items
        ON item_quantities.item_id = inventory.items.item_id;
        
        UPDATE @item_quantities
        SET in_stock = inventory.count_item_in_stock(item_id, base_unit_id, store_id)
        WHERE maintain_inventory = 1;


        IF EXISTS
        (
            SELECT TOP 1 0 FROM @item_quantities
            WHERE total_sales > in_stock
            AND maintain_inventory = 1     
        )
        BEGIN
			SET @error_message = 'Negative stock is not allowed. <br /> <br />';

			SELECT @error_message = @error_message + inventory.get_item_name_by_item_id(item_id) + ' --> required: ' + CAST(quantity AS varchar(50))+ ', actual: ' + CAST(inventory.convert_unit(base_unit_id, unit_id) * in_stock AS varchar(50)) + ' / ' + inventory.get_unit_name_by_unit_id(unit_id) +  ' <br />'
			FROM @item_quantities
            WHERE total_sales > in_stock
            AND maintain_inventory = 1     

            RAISERROR(@error_message, 13, 1);
        END;
        
        IF EXISTS
        (
            SELECT TOP 1 0 FROM @checkout_details AS details
            WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
        )
        BEGIN
            RAISERROR('Item/unit mismatch.', 13, 1);
        END;

		SELECT 
			@taxable_total		= COALESCE(SUM(CASE WHEN is_taxable_item = 1 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
			@nontaxable_total	= COALESCE(SUM(CASE WHEN is_taxable_item = 0 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
		FROM @checkout_details;


        SELECT @discount_total  = ROUND(SUM(COALESCE(discount, 0)), 2) FROM @checkout_details;
        SELECT @shipping_charge = SUM(COALESCE(shipping_charge, 0)) FROM @checkout_details;
            

        SET @coupon_discount                = ROUND(@discount, 2);

        IF(@is_flat_discount = 0 AND COALESCE(@discount, 0) > 0)
        BEGIN
            SET @coupon_discount            = ROUND(COALESCE(@taxable_total, 0) * (@discount/100), 2);
        END;

		IF(@coupon_discount > @taxable_total)
		BEGIN
			RAISERROR('The coupon discount cannot be greater than total taxable amount.', 16, 1);
		END;


        SELECT @tax_total       = ROUND((COALESCE(@taxable_total, 0) - COALESCE(@coupon_discount, 0)) * (@sales_tax_rate / 100), 2);
        SELECT @grand_total     = COALESCE(@taxable_total, 0) + COALESCE(@nontaxable_total, 0) + COALESCE(@tax_total, 0) - COALESCE(@coupon_discount, 0);

		SET @receivable         = @grand_total;


        IF(@is_flat_discount = 1 AND @discount > @receivable)
        BEGIN
			SET @error_message = FORMATMESSAGE('The discount amount %s cannot be greater than total amount %s.', CAST(@discount AS varchar(30)), CAST(@receivable AS varchar(30)));
            RAISERROR(@error_message, 13, 1);
        END
        ELSE IF(@is_flat_discount = 0 AND @discount > 100)
        BEGIN
            RAISERROR('The discount rate cannot be greater than 100.', 13, 1);
        END;

        IF(@tender > 0)
        BEGIN
            IF(@tender < @receivable)
            BEGIN
                SET @error_message = FORMATMESSAGE('The tender amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END
        ELSE IF(@check_amount > 0)
        BEGIN
            IF(@check_amount < @receivable )
            BEGIN
                SET @error_message = FORMATMESSAGE('The check amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END
        ELSE IF(COALESCE(@gift_card_number, '') != '')
        BEGIN
            IF(@gift_card_balance < @receivable )
            BEGIN
                SET @error_message = FORMATMESSAGE('The gift card must have a balance of at least %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END;
        


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
        FROM @checkout_details
        GROUP BY sales_account_id;

        IF(@is_periodic = 0)
        BEGIN
            --Perpetutal Inventory Accounting System
            UPDATE @checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);

            SELECT @cost_of_goods = SUM(cost_of_goods_sold)
            FROM @checkout_details;


            IF(@cost_of_goods > 0)
            BEGIN
                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Dr', cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY cost_of_goods_sold_account_id;

                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Cr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY inventory_account_id;
            END;
        END;

        IF(COALESCE(@tax_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
        END;

        IF(COALESCE(@shipping_charge, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory.get_account_id_by_shipper_id(@shipper_id), @statement_reference, @default_currency_code, @shipping_charge, 1, @default_currency_code, @shipping_charge;                
        END;


        IF(COALESCE(@discount_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
            FROM @checkout_details
            GROUP BY sales_discount_account_id
            HAVING SUM(COALESCE(discount, 0)) > 0;
        END;

        IF(COALESCE(@coupon_discount, 0) > 0)
        BEGIN
			DECLARE @sales_discount_account_id integer;

			SELECT @sales_discount_account_id = inventory.stores.sales_discount_account_id
			FROM inventory.stores
			WHERE inventory.stores.store_id = @store_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', @sales_discount_account_id, @statement_reference, @default_currency_code, @coupon_discount, 1, @default_currency_code, @coupon_discount;
        END;


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @receivable, 1, @default_currency_code, @receivable;
        
		IF
		(
			SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
			FROM @temp_transaction_details
		) != 0
		BEGIN
			SELECT finance.get_account_name_by_account_id(account_id), * FROM @temp_transaction_details ORDER BY tran_type;
			RAISERROR('Could not balance the Journal Entry. Nothing was saved.', 16, 1);		
		END;
		

        SET @tran_counter           = finance.get_new_transaction_counter(@value_date);
        SET @transaction_code       = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

        
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
        SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        SET @transaction_master_id  = SCOPE_IDENTITY();
        UPDATE @temp_transaction_details        SET transaction_master_id   = @transaction_master_id;


        INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @value_date, @book_date, @office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;

        INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, shipper_id, posted_by, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
        SELECT @book_name, @value_date, @book_date, @transaction_master_id, @shipper_id, @user_id, @office_id, @coupon_discount, @taxable_total, @sales_tax_rate, @tax_total, @nontaxable_total;

        SET @checkout_id              = SCOPE_IDENTITY();    
        
        UPDATE @checkout_details
        SET checkout_id             = @checkout_id;

        INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount_rate, discount, shipping_charge, is_taxed)
        SELECT @value_date, @book_date, checkout_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, COALESCE(cost_of_goods_sold, 0), discount_rate, discount, shipping_charge, is_taxable_item
        FROM @checkout_details;


        SELECT @invoice_number = COALESCE(MAX(invoice_number), 0) + 1
        FROM sales.sales
        WHERE sales.sales.fiscal_year_code = @fiscal_year_code;
        

        IF(@is_credit = 0 AND @book_name = 'Sales Entry')
        BEGIN
            EXECUTE sales.post_receipt
                @user_id, 
                @office_id, 
                @login_id,
                @customer_id,
                @default_currency_code, 
                1.0, 
                1.0,
                @reference_number, 
                @statement_reference, 
                @cost_center_id,
                @cash_account_id,
                @cash_repository_id,
                @value_date,
                @book_date,
                @receivable,
                @tender,
                @change,
                @check_amount,
                @check_bank_name,
                @check_number,
                @check_date,
                @gift_card_number,
                @store_id,
                @transaction_master_id,--CASCADING TRAN ID
				@receipt_transaction_master_id OUTPUT;

			EXECUTE finance.auto_verify @receipt_transaction_master_id, @office_id;

			IF @serial_number_ids IS NOT NULL
			BEGIN
				DECLARE @sql nvarchar(max) = 
				'UPDATE inventory.serial_numbers SET sales_transaction_id = '+ CAST(@transaction_master_id AS nvarchar(50))+'
				WHERE serial_number_id IN (' + @serial_number_ids + ')'

				EXEC sp_executesql @sql;
			END
        END
        ELSE
        BEGIN

            EXECUTE sales.settle_customer_due @customer_id, @office_id;
        END;

		IF(@book_name = 'Sales Entry')
		BEGIN
			INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id, receipt_transaction_master_id)
			SELECT @fiscal_year_code, @invoice_number, @price_type_id, @counter_id, @receivable, @cash_repository_id, @sales_order_id, @sales_quotation_id, @transaction_master_id, @checkout_id, @customer_id, @user_id, @coupon_id, @is_flat_discount, @discount, @discount_total, @is_credit, @payment_term_id, @tender, @change, @check_number, @check_date, @check_bank_name, @check_amount, @gift_card_id, @receipt_transaction_master_id;
		END;
		        
		EXECUTE finance.auto_verify @transaction_master_id, @office_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


-- DECLARE @office_id								integer 							= (SELECT TOP 1 office_id FROM core.offices);
-- DECLARE @user_id                                integer 							= (SELECT TOP 1 user_id FROM account.users);
-- DECLARE @login_id                               bigint  							= (SELECT TOP 1 login_id FROM account.logins WHERE user_id = @user_id);
-- DECLARE @counter_id                             integer								= (SELECT TOP 1 counter_id FROM inventory.counters);
-- DECLARE @value_date                             date								= finance.get_value_date(@office_id);
-- DECLARE @book_date                              date								= finance.get_value_date(@office_id);
-- DECLARE @cost_center_id                         integer								= (SELECT TOP 1 cost_center_id FROM finance.cost_centers);
-- DECLARE @reference_number                       national character varying(24)		= 'N/A';
-- DECLARE @statement_reference                    national character varying(2000)	= 'Test';
-- DECLARE @tender                                 numeric(30, 6)						= 20000;
-- DECLARE @change                                 numeric(30, 6)						= 10;
-- DECLARE @payment_term_id                        integer								= NULL;
-- DECLARE @check_amount                           numeric(30, 6)						= NULL;
-- DECLARE @check_bank_name                        national character varying(1000)	= NULL;
-- DECLARE @check_number                           national character varying(100)		= NULL;
-- DECLARE @check_date                             date								= NULL;
-- DECLARE @gift_card_number                       national character varying(100)		= NULL;
-- DECLARE @customer_id                            integer								= (SELECT TOP 1 customer_id FROM inventory.customers);
-- DECLARE @price_type_id                          integer								= (SELECT TOP 1 price_type_id FROM sales.price_types);
-- DECLARE @shipper_id                             integer								= (SELECT TOP 1 shipper_id FROM inventory.shippers);
-- DECLARE @store_id                               integer								= (SELECT TOP 1 store_id FROM inventory.stores WHERE store_name='Cold Room RM');
-- DECLARE @coupon_code                            national character varying(100)		= NULL;
-- DECLARE @is_flat_discount                       bit									= 0;
-- DECLARE @discount                               numeric(30, 6)						= 20;
-- DECLARE @details                                sales.sales_detail_type;
-- DECLARE @sales_quotation_id                     bigint								= NULL;
-- DECLARE @sales_order_id                         bigint								= NULL;
-- DECLARE @transaction_master_id                  bigint								= NULL;

-- INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, shipping_charge, discount_rate, discount)  
-- --SELECT @store_id, 'Cr', item_id, 1, unit_id, selling_price, 0, selling_price * 0.13, 0
-- --FROM inventory.items
-- --WHERE inventory.items.item_code IN('SHS0003', 'SHS0004');
-- SELECT @store_id, 'Cr', 1, 1, 6, 2320, 100, 0, 0;


-- EXECUTE sales.post_sales
    -- @office_id,
    -- @user_id,
    -- @login_id,
    -- @counter_id,
    -- @value_date,
    -- @book_date,
    -- @cost_center_id,
    -- @reference_number,
    -- @statement_reference,
    -- @tender,
    -- @change, 
    -- @payment_term_id,
	-- @check_amount,
    -- @check_bank_name,
    -- @check_number,
    -- @check_date,
	-- @gift_card_number,
    -- @customer_id,    
    -- @price_type_id,
    -- @shipper_id,
    -- @store_id,
    -- @coupon_code,
    -- @is_flat_discount,
    -- @discount,
    -- @details,
    -- @sales_quotation_id,
    -- @sales_order_id,  
    -- @transaction_master_id OUTPUT;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.settle_customer_due.sql --<--<--
IF OBJECT_ID('sales.settle_customer_due') IS NOT NULL
DROP PROCEDURE sales.settle_customer_due;

GO

CREATE PROCEDURE sales.settle_customer_due(@customer_id integer, @office_id integer)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @settled_transactions TABLE
    (
        transaction_master_id               bigint
    );

    DECLARE @settling_amount                numeric(30, 6);
    DECLARE @closing_balance                numeric(30, 6);
    DECLARE @total_sales                    numeric(30, 6);
    DECLARE @customer_account_id            integer = inventory.get_account_id_by_customer_id(@customer_id);

    --Closing balance of the customer
    SELECT
        @closing_balance = SUM
        (
            CASE WHEN tran_type = 'Cr' 
            THEN amount_in_local_currency 
            ELSE amount_in_local_currency  * -1 
            END
        )
    FROM finance.transaction_details
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.deleted = 0
    AND finance.transaction_master.office_id = @office_id
    AND finance.transaction_details.account_id = @customer_account_id;


    --Since customer account is receivable, change the balance to debit
    SET @closing_balance = @closing_balance * -1;

    --Sum of total sales amount
    SELECT 
        @total_sales = SUM
        (
            COALESCE(inventory.checkouts.taxable_total, 0) + 
            COALESCE(inventory.checkouts.tax, 0) + 
            COALESCE(inventory.checkouts.nontaxable_total, 0) - 
            COALESCE(inventory.checkouts.discount, 0)             
        )
    FROM inventory.checkouts
    INNER JOIN sales.sales
    ON sales.sales.checkout_id = inventory.checkouts.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.office_id = @office_id
    AND sales.sales.customer_id = @customer_id;


    SET @settling_amount = @total_sales - @closing_balance;

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
        WHERE finance.transaction_master.book IN('Sales.Direct', 'Sales.Delivery')
        AND finance.transaction_master.office_id = @office_id
        AND finance.transaction_master.verification_status_id > 0      --Approved
        AND sales.sales.customer_id = @customer_id                     --of this customer
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

    INSERT INTO @settled_transactions
    SELECT transaction_master_id
    FROM sales_summary
    WHERE cumulative_due <= @settling_amount;

    UPDATE sales.sales
    SET credit_settled = 1
    WHERE transaction_master_id IN
    (
        SELECT transaction_master_id 
        FROM @settled_transactions
    );
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/02.functions-and-logic/sales.validate_items_for_return.sql --<--<--
IF OBJECT_ID('sales.validate_items_for_return') IS NOT NULL
DROP FUNCTION sales.validate_items_for_return;

GO

CREATE FUNCTION sales.validate_items_for_return
(
    @transaction_master_id                  bigint, 
    @details                                sales.sales_detail_type READONLY
)
RETURNS @result TABLE
(
    is_valid                                bit,
    "error_message"                         national character varying(2000)
)
AS
BEGIN        
    DECLARE @checkout_id                    bigint = 0;
    DECLARE @item_id                        integer = 0;
    DECLARE @factor_to_base_unit            numeric(30, 6);
    DECLARE @returned_in_previous_batch     numeric(30, 6) = 0;
    DECLARE @in_verification_queue          numeric(30, 6) = 0;
    DECLARE @actual_price_in_root_unit      numeric(30, 6) = 0;
    DECLARE @price_in_root_unit             numeric(30, 6) = 0;
    DECLARE @item_in_stock                  numeric(30, 6) = 0;
    DECLARE @error_item_id                  integer;
    DECLARE @error_quantity                 numeric(30, 6);
    DECLARE @error_unit						national character varying(500);
    DECLARE @error_amount                   numeric(30, 6);
    DECLARE @error_message                  national character varying(MAX);

    DECLARE @total_rows                     integer = 0;
    DECLARE @counter                        integer = 0;
    DECLARE @loop_id                        integer;
    DECLARE @loop_item_id                   integer;
    DECLARE @loop_price                     numeric(30, 6);
    DECLARE @loop_base_quantity             numeric(30, 6);

    SET @checkout_id                        = inventory.get_checkout_id_by_transaction_master_id(@transaction_master_id);

    INSERT INTO @result(is_valid, "error_message")
    SELECT 0, '';


    DECLARE @details_temp TABLE
    (
        id                  integer IDENTITY,
        store_id            integer,
        item_id             integer,
        item_in_stock       numeric(30, 6),
        quantity            numeric(30, 6),        
        unit_id             integer,
        price               numeric(30, 6),
        discount_rate       numeric(30, 6),
        discount			numeric(30, 6),
        is_taxed			bit,
        shipping_charge     numeric(30, 6),
        root_unit_id        integer,
        base_quantity       numeric(30, 6)
    ) ;

    INSERT INTO @details_temp(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
    FROM @details;

    UPDATE @details_temp
    SET 
        item_in_stock = inventory.count_item_in_stock(item_id, unit_id, store_id);
       
    UPDATE @details_temp
    SET root_unit_id = inventory.get_root_unit_id(unit_id);

    UPDATE @details_temp
    SET base_quantity = inventory.convert_unit(unit_id, root_unit_id) * quantity;


    --Determine whether the quantity of the returned item(s) is less than or equal to the same on the actual transaction
    DECLARE @item_summary TABLE
    (
        store_id                    integer,
        item_id                     integer,
        root_unit_id                integer,
        returned_quantity           numeric(30, 6),
        actual_quantity             numeric(30, 6),
        returned_in_previous_batch  numeric(30, 6),
        in_verification_queue       numeric(30, 6)
    ) ;
    
    INSERT INTO @item_summary(store_id, item_id, root_unit_id, returned_quantity)
    SELECT
        store_id,
        item_id,
        root_unit_id, 
        SUM(base_quantity)
    FROM @details_temp
    GROUP BY 
        store_id, 
        item_id,
        root_unit_id;

    UPDATE @item_summary
    SET actual_quantity = 
    (
        SELECT SUM(base_quantity)
        FROM inventory.checkout_details
        WHERE inventory.checkout_details.checkout_id = @checkout_id
        AND inventory.checkout_details.item_id = item_summary.item_id
    )
    FROM @item_summary AS item_summary;

    UPDATE @item_summary
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
                WHERE transaction_master_id = @transaction_master_id
            )
        )
        AND item_id = item_summary.item_id
    )
    FROM @item_summary AS item_summary;

    UPDATE @item_summary
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
                WHERE transaction_master_id = @transaction_master_id
            )
        )
        AND item_id = item_summary.item_id
    )
    FROM @item_summary AS item_summary;
    
    --Determine whether the price of the returned item(s) is less than or equal to the same on the actual transaction
    DECLARE @cumulative_pricing TABLE
    (
        item_id                     integer,
        base_price                  numeric(30, 6),
        allowed_returns             numeric(30, 6)
    ) ;

    INSERT INTO @cumulative_pricing
    SELECT 
        item_id,
        MIN(price  / base_quantity * quantity) as base_price,
        SUM(base_quantity) OVER(ORDER BY item_id, base_quantity) as allowed_returns
    FROM inventory.checkout_details 
    WHERE checkout_id = @checkout_id
    GROUP BY item_id, base_quantity;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE store_id IS NULL OR store_id <= 0)
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid store.';
        RETURN;
    END;    

    IF EXISTS(SELECT 0 FROM @details_temp WHERE item_id IS NULL OR item_id <= 0)
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid item.';

        RETURN;
    END;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE unit_id IS NULL OR unit_id <= 0)
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid unit.';
        RETURN;
    END;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE quantity IS NULL OR quantity <= 0)
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid quantity.';
        RETURN;
    END;

    IF(@checkout_id  IS NULL OR @checkout_id  <= 0)
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid transaction id.';
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE transaction_master_id = @transaction_master_id
        AND verification_status_id > 0
    )
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid or rejected transaction.' ;
        RETURN;
    END;
        
    SELECT @item_id = item_id
    FROM @details_temp
    WHERE item_id NOT IN
    (
        SELECT item_id FROM inventory.checkout_details
        WHERE checkout_id = @checkout_id
    );

    IF(COALESCE(@item_id, 0) != 0)
    BEGIN
        SET @error_message = FORMATMESSAGE('The item %s is not associated with this transaction.', inventory.get_item_name_by_item_id(@item_id));

        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = @error_message;
        RETURN;
    END;


    IF NOT EXISTS
    (
        SELECT TOP 1 0 FROM inventory.checkout_details
        INNER JOIN @details_temp AS details_temp
        ON inventory.checkout_details.item_id = details_temp.item_id
        WHERE checkout_id = @checkout_id
        AND inventory.get_root_unit_id(details_temp.unit_id) = inventory.get_root_unit_id(inventory.checkout_details.unit_id)
    )
    BEGIN
        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = 'Invalid or incompatible unit specified.';
        RETURN;
    END;

    SELECT TOP 1
        @error_item_id = item_id,
        @error_quantity = returned_quantity,
		@error_unit = inventory.get_unit_name_by_unit_id(root_unit_id)
    FROM @item_summary
    WHERE returned_quantity + returned_in_previous_batch + in_verification_queue > actual_quantity;

    IF(@error_item_id IS NOT NULL)
    BEGIN
        SET @error_message = FORMATMESSAGE('The returned quantity (%s %s) of %s is greater than actual quantity.', CAST(@error_quantity AS varchar(30)), @error_unit, inventory.get_item_name_by_item_id(@error_item_id));

        UPDATE @result 
        SET 
            is_valid = 0, 
            "error_message" = @error_message;
        RETURN;
    END;


    SELECT @total_rows = MAX(id) FROM @details_temp;

    WHILE @counter <= @total_rows
    BEGIN

        SELECT TOP 1
            @loop_id                = id,
            @loop_item_id           = item_id,
            @loop_price             = CAST((price / base_quantity * quantity) AS numeric(30, 6)),
            @loop_base_quantity     = base_quantity
        FROM @details_temp
        WHERE id >= @counter
        ORDER BY id;

        IF(@loop_id IS NOT NULL)
        BEGIN
            SET @counter = @loop_id + 1;        
        END
        ELSE
        BEGIN
            BREAK;
        END;


        SELECT TOP 1
            @error_item_id = item_id,
            @error_amount = base_price
        FROM @cumulative_pricing
        WHERE item_id = @loop_item_id
        AND base_price <  @loop_price
        AND allowed_returns >= @loop_base_quantity;
        
        IF (@error_item_id IS NOT NULL)
        BEGIN
            SET @error_message = FORMATMESSAGE
            (
                'The returned base amount %s of %s cannot be greater than actual amount %s.', 
                CAST(@loop_price AS varchar(30)), 
                inventory.get_item_name_by_item_id(@error_item_id), 
                CAST(@error_amount AS varchar(30))
            );

            UPDATE @result 
            SET 
                is_valid = 0, 
                "error_message" = @error_message;
        RETURN;
        END;
    END;
    
    UPDATE @result 
    SET 
        is_valid = 1, 
        "error_message" = '';
    RETURN;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/03.menus/menus.sql --<--<--
EXECUTE core.create_menu 'MixERP.Sales', 'Customers', 'Customers', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/Customers.xml', 'users', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesDetails', 'Sales Details', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesDetails.xml', 'money', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesSummary', 'Sales Summary', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesSummary.xml', 'money', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'LeastSellingItems', 'Least Selling Items', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/LeastSellingItems.xml', 'map signs', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesReturnReport', 'Sales Return Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesReturn.xml', 'map signs', 'Reports';


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/00.sales.sales_view.sql --<--<--
IF OBJECT_ID('sales.sales_view') IS NOT NULL
DROP VIEW sales.sales_view;

GO

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
    inventory.checkouts.discount,
    inventory.checkouts.tax_rate,
    inventory.checkouts.tax,
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
    sales.gift_cards.first_name + ' ' + sales.gift_cards.middle_name + ' ' + sales.gift_cards.last_name AS gift_card_owner,
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
LEFT JOIN finance.cash_repositories
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
WHERE finance.transaction_master.deleted = 0;


--SELECT * FROM sales.sales_view

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/01. sales.customer_transaction_view.sql --<--<--
IF OBJECT_ID('sales.customer_transaction_view') IS NOT NULL
DROP VIEW sales.customer_transaction_view;
GO

CREATE VIEW sales.customer_transaction_view 
AS 
SELECT 
    sales_view.value_date,
    sales_view.book_date,
    sales_view.transaction_master_id,
    sales_view.transaction_code,
    sales_view.invoice_number,
    sales_view.customer_id,
    'Invoice' AS statement_reference,
    sales_view.total_amount + COALESCE(sales_view.check_amount, 0) - sales_view.total_discount_amount AS debit,
    NULL AS credit
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
    'Payment' AS statement_reference,
    NULL AS debit,
    sales_view.total_amount + COALESCE(sales_view.check_amount, 0) - sales_view.total_discount_amount AS credit
FROM sales.sales_view
WHERE sales_view.verification_status_id > 0 AND sales_view.is_credit = 0
UNION ALL

SELECT 
    sales_view.value_date,
    sales_view.book_date,
    sales_view.transaction_master_id,
    sales_view.transaction_code,
    sales_view.invoice_number,
    returns.customer_id,
    'Return' AS statement_reference,
    NULL AS debit,
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
    NULL AS invoice_number,
    customer_receipts.customer_id,
    'Payment' AS statement_reference,
    NULL AS debit,
    customer_receipts.amount AS credit
FROM sales.customer_receipts
JOIN finance.transaction_master ON customer_receipts.transaction_master_id = transaction_master.transaction_master_id
WHERE transaction_master.verification_status_id > 0;

GO

--SELECT * FROM sales.customer_transaction_view;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.coupon_view.sql --<--<--
IF OBJECT_ID('sales.coupon_view') IS NOT NULL
DROP VIEW sales.coupon_view;

GO



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



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.customer_receipt_search_view.sql --<--<--
IF OBJECT_ID('sales.customer_receipt_search_view') IS NOT NULL
DROP VIEW sales.customer_receipt_search_view;

GO

CREATE VIEW sales.customer_receipt_search_view
AS
SELECT
	sales.customer_receipts.transaction_master_id AS tran_id,
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
WHERE finance.transaction_master.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.gift_card_search_view.sql --<--<--
IF OBJECT_ID('sales.gift_card_search_view') IS NOT NULL
DROP VIEW sales.gift_card_search_view;

GO



CREATE VIEW sales.gift_card_search_view
AS
SELECT
    sales.gift_cards.gift_card_id,
    sales.gift_cards.gift_card_number,
    REPLACE(COALESCE(sales.gift_cards.first_name + ' ', '') + COALESCE(sales.gift_cards.middle_name + ' ', '') + COALESCE(sales.gift_cards.last_name, ''), '  ', ' ') AS name,
    REPLACE(COALESCE(sales.gift_cards.address_line_1 + ' ', '') + COALESCE(sales.gift_cards.address_line_2 + ' ', '') + COALESCE(sales.gift_cards.street, ''), '  ', ' ') AS address,
    sales.gift_cards.city,
    sales.gift_cards.state,
    sales.gift_cards.country,
    sales.gift_cards.po_box,
    sales.gift_cards.zip_code,
    sales.gift_cards.phone_numbers,
    sales.gift_cards.fax    
FROM sales.gift_cards
WHERE sales.gift_cards.deleted = 0;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.gift_card_transaction_view.sql --<--<--
IF OBJECT_ID('sales.gift_card_transaction_view') IS NOT NULL
DROP VIEW sales.gift_card_transaction_view;

GO



CREATE VIEW sales.gift_card_transaction_view
AS
SELECT
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_ts,
finance.transaction_master.transaction_code,
finance.transaction_master.value_date,
finance.transaction_master.book_date,
account.users.name AS entered_by,
sales.gift_cards.first_name + ' ' + sales.gift_cards.middle_name + ' ' + sales.gift_cards.last_name AS customer_name,
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

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.item_view.sql --<--<--
IF OBJECT_ID('sales.item_view') IS NOT NULL
DROP VIEW sales.item_view;

GO



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
    inventory.get_associated_unit_list_csv(inventory.items.unit_id) AS valid_units,
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
WHERE inventory.items.deleted = 0
AND inventory.items.allow_sales = 1;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.order_search_view.sql --<--<--
IF OBJECT_ID('sales.order_search_view') IS NOT NULL
DROP VIEW sales.order_search_view;

GO

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
	sales.orders.priority,
	sales.orders.cancelled
FROM sales.orders;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.quotation_search_view.sql --<--<--
IF OBJECT_ID('sales.quotation_search_view') IS NOT NULL
DROP VIEW sales.quotation_search_view;

GO

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

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.return_search_view.sql --<--<--
IF OBJECT_ID('sales.return_search_view') IS NOT NULL
DROP VIEW sales.return_search_view;

GO

CREATE VIEW sales.return_search_view
AS
SELECT
	finance.transaction_master.transaction_master_id AS tran_id,
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
WHERE finance.transaction_master.deleted = 0
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

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/05.views/sales.sales_search_view.sql --<--<--
IF OBJECT_ID('sales.sales_search_view') IS NOT NULL
DROP VIEW sales.sales_search_view;

GO

CREATE VIEW sales.sales_search_view
AS
SELECT 
    CAST(finance.transaction_master.transaction_master_id AS varchar(100)) AS tran_id,
    finance.transaction_master.transaction_code AS tran_code,
	sales.sales.invoice_number,
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
WHERE finance.transaction_master.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.1.update/src/99.ownership.sql --<--<--
IF(IS_ROLEMEMBER ('db_owner') = 1)
BEGIN
	EXEC sp_addrolemember  @rolename = 'db_owner', @membername  = 'frapid_db_user';
END
GO

IF(IS_ROLEMEMBER ('db_owner') = 1)
BEGIN
	EXEC sp_addrolemember  @rolename = 'db_datareader', @membername  = 'report_user'
END
GO

DECLARE @proc sysname
DECLARE @cmd varchar(8000)

DECLARE cur CURSOR FOR 
SELECT '[' + schema_name(schema_id) + '].[' + name + ']' FROM sys.objects
WHERE type IN('FN')
AND is_ms_shipped = 0
ORDER BY 1
OPEN cur
FETCH next from cur into @proc
WHILE @@FETCH_STATUS = 0
BEGIN
     SET @cmd = 'GRANT EXEC ON ' + @proc + ' TO report_user';
     EXEC (@cmd)

     FETCH next from cur into @proc
END
CLOSE cur
DEALLOCATE cur

GO

