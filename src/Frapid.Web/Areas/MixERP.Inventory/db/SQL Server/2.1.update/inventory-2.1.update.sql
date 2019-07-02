-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
IF COL_LENGTH('inventory.inventory_setup', 'validate_returns') IS NULL
BEGIN
    ALTER TABLE inventory.inventory_setup
    ADD validate_returns bit NOT NULL DEFAULT(1)
END



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_account_statement.sql --<--<--
IF OBJECT_ID('inventory.get_account_statement') IS NOT NULL
DROP FUNCTION inventory.get_account_statement;

GO

CREATE FUNCTION inventory.get_account_statement
(
    @value_date_from        date,
    @value_date_to          date,
    @user_id                integer,
    @item_id                integer,
    @store_id               integer
)
RETURNS @result TABLE
(
    id                      integer IDENTITY,
    value_date              date,
    book_date               date,
	store_name				national character varying(500),
    tran_code				national character varying(50),
    statement_reference     national character varying(2000),
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    balance                 numeric(30, 6),
    book                    national character varying(50),
    item_id                 integer,
    item_code				national character varying(50),
    item_name               national character varying(1000),
    posted_on               DATETIMEOFFSET,
    posted_by               national character varying(1000),
    approved_by             national character varying(1000),
    verification_status     integer
)
AS
BEGIN
    INSERT INTO @result(value_date, book_date, store_name, statement_reference, debit, item_id)
    SELECT 
        @value_date_from, 
        @value_date_from, 
		'',
        'Opening Balance',
        SUM
        (
            CASE inventory.checkout_details.transaction_type
            WHEN 'Dr' THEN base_quantity
            ELSE base_quantity * -1 
            END            
        ) as debit,
        @item_id
    FROM inventory.checkout_details
    INNER JOIN inventory.checkouts
    ON inventory.checkout_details.checkout_id = inventory.checkouts.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date < @value_date_from
    AND (COALESCE(@store_id, 0) = 0 OR inventory.checkout_details.store_id = @store_id)
    AND inventory.checkout_details.item_id = @item_id;

    DELETE FROM @result
    WHERE COALESCE(debit, 0) = 0
    AND COALESCE(credit, 0) = 0;

    UPDATE @result SET 
    debit = credit * -1,
    credit = 0
    WHERE credit < 0;

    INSERT INTO @result(value_date, book_date, store_name, tran_code, statement_reference, debit, credit, book, item_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
		inventory.get_store_name_by_store_id(inventory.checkout_details.store_id),
        finance.transaction_master.transaction_code,
        finance.transaction_master.statement_reference,
        CASE inventory.checkout_details.transaction_type
        WHEN 'Dr' THEN base_quantity
        ELSE 0 END AS debit,
        CASE inventory.checkout_details.transaction_type
        WHEN 'Cr' THEN base_quantity
        ELSE 0 END AS credit,
        finance.transaction_master.book,
        inventory.checkout_details.item_id,
        finance.transaction_master.transaction_ts AS posted_on,
        account.get_name_by_user_id(finance.transaction_master.user_id),
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id),
        finance.transaction_master.verification_status_id
    FROM finance.transaction_master
    INNER JOIN inventory.checkouts
    ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_Id
    INNER JOIN inventory.checkout_details
    ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date >= @value_date_from
    AND finance.transaction_master.value_date <= @value_date_to
    AND (COALESCE(@store_id, 0) = 0 OR inventory.checkout_details.store_id = @store_id)
    AND inventory.checkout_details.item_id = @item_id
    ORDER BY 
        finance.transaction_master.value_date,
        finance.transaction_master.last_verified_on;
    
    UPDATE result
    SET balance = c.balance
    FROM @result AS result
	INNER JOIN
    (
		SELECT id, 
		  balance = SUM(COALESCE(c.debit, 0) - COALESCE(c.credit, 0)) OVER (ORDER BY id)
		FROM @result AS c
    ) AS c
    ON result.id = c.id;

    UPDATE @result 
    SET
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name
    FROM @result AS result 
    INNER JOIN inventory.items
    ON result.item_id = inventory.items.item_id;

	DECLARE @unit_id		int;
	DECLARE @base_unit_id	int;
	SELECT @unit_id = unit_id
	FROM inventory.items WHERE item_id=@item_id;

	SELECT TOP 1 @base_unit_id = base_unit_id
	FROM inventory.checkout_details WHERE item_id=@item_id;

	UPDATE @result SET debit = debit * inventory.convert_unit(@base_unit_id, @unit_id),
		credit = credit * inventory.convert_unit(@base_unit_id, @unit_id),
		balance = balance * inventory.convert_unit(@base_unit_id, @unit_id);

    RETURN;        
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_associated_unit_list.sql --<--<--
IF OBJECT_ID('inventory.get_associated_unit_list') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_list;

GO

CREATE FUNCTION inventory.get_associated_unit_list(@any_unit_id integer)
RETURNS @result TABLE
(
    unit_id             integer
)
AS
BEGIN
    DECLARE @root_unit_id integer = inventory.get_root_unit_id(@any_unit_id);
        
    INSERT INTO @result(unit_id) 
    SELECT @root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM @result
        WHERE unit_id=@root_unit_id
    );
    
    WITH cte(unit_id)
    AS
    (
		SELECT 
			compare_unit_id
		FROM 
			inventory.compound_units
		WHERE base_unit_id = @root_unit_id
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
    
    INSERT INTO @result(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM @result
    WHERE unit_id IS NULL;
    
    RETURN;
END;



--SELECT * FROM inventory.get_associated_unit_list(1);

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_associated_units.sql --<--<--
IF OBJECT_ID('inventory.get_associated_unit_csv_list') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_csv_list;

GO

CREATE FUNCTION inventory.get_associated_unit_csv_list(@any_unit_id integer)
RETURNS @result TABLE
(
    unit_id             integer
)
AS
BEGIN
    DECLARE @root_unit_id integer = inventory.get_root_unit_id(@any_unit_id);
        
    INSERT INTO @result(unit_id) 
    SELECT @root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM @result
        WHERE unit_id=@root_unit_id
    );
    
    WITH cte(unit_id)
    AS
    (
         SELECT 
            compare_unit_id
         FROM 
            inventory.compound_units
         WHERE 
            base_unit_id = @root_unit_id
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
    
    INSERT INTO @result(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM @result
    WHERE unit_id IS NULL;
    
    RETURN;
END;



GO


--SELECT * FROM inventory.get_associated_unit_list(24);


IF OBJECT_ID('inventory.get_associated_unit_list_csv') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_list_csv;

GO

CREATE FUNCTION inventory.get_associated_unit_list_csv(@any_unit_id integer)
RETURNS varchar(MAX)
AS
BEGIN
    DECLARE @result TABLE
    (
        unit_id integer, 
        unit_code national character varying(24), 
        unit_name national character varying(500)
    );

    DECLARE @csv varchar(MAX);
    INSERT INTO @result(unit_id)
    SELECT * FROM inventory.get_associated_unit_list(@any_unit_id);

    SELECT @csv = COALESCE(@csv + ',', '') +  CONVERT(varchar, unit_id)
    FROM @result
    ORDER BY unit_id;
        
    RETURN @csv;
END;



GO


--SELECT inventory.get_associated_unit_list_csv(24);




-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_brand_id_by_brand_name.sql --<--<--
IF OBJECT_ID('inventory.get_brand_id_by_brand_name') IS NOT NULL
DROP FUNCTION inventory.get_brand_id_by_brand_name;

GO

CREATE FUNCTION inventory.get_brand_id_by_brand_name(@brand_name national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT brand_id
	    FROM inventory.brands
	    WHERE inventory.brands.brand_name=@brand_name
	    AND inventory.brands.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_cost_of_goods_sold.sql --<--<--
IF OBJECT_ID('inventory.get_cost_of_goods_sold') IS NOT NULL
DROP FUNCTION inventory.get_cost_of_goods_sold;

GO

CREATE FUNCTION inventory.get_cost_of_goods_sold(@item_id integer, @unit_id integer, @store_id integer, @quantity numeric(30, 6))
RETURNS numeric(30, 6)
AS
BEGIN
	IF(@quantity = 0)
	BEGIN
		RETURN 0;
	END;

    DECLARE @backup_quantity            numeric(30, 6);
    DECLARE @base_quantity              numeric(30, 6);
    DECLARE @base_unit_id               integer;
    DECLARE @base_unit_cost             numeric(30, 6);
    DECLARE @total_sold                 integer;
    DECLARE @office_id                  integer = inventory.get_office_id_by_store_id(@store_id);
    DECLARE @method                     national character varying(1000) = inventory.get_cost_of_good_method(@office_id);

    --backup base quantity in numeric(30, 6)
    SET @backup_quantity                = inventory.get_base_quantity_by_unit_id(@unit_id, @quantity);
    --convert base quantity to whole number
    SET @base_quantity                  = CEILING(@backup_quantity);
    SET @base_unit_id                   = inventory.get_root_unit_id(@unit_id);
        
    IF(@method = 'MAVCO')
    BEGIN
        RETURN inventory.get_mavcogs(@item_id, @store_id, @base_quantity, 1.00);
    END; 

	--GET THE SUM TOTAL QUANTITIES SOLD IN THIS STORE
    SELECT @total_sold = COALESCE(SUM(base_quantity), 0)
    FROM inventory.verified_checkout_details_view
    WHERE transaction_type='Cr'
    AND item_id = @item_id
	AND store_id = @store_id;

	IF(@method = 'FIFO')
	BEGIN
		WITH all_purchases
		AS
		(
			SELECT ROW_NUMBER() OVER(ORDER BY value_date, checkout_detail_id) AS id, *
			FROM inventory.verified_checkout_details_view
			WHERE item_id = @item_id
			AND store_id = @store_id
			AND transaction_type = 'Dr'
			AND base_quantity != 0
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
		),
		details
		AS
		(
			SELECT
			  base_quantity - 
			  CASE WHEN total < @total_sold THEN base_quantity 
				   WHEN lag < @total_sold THEN @total_sold - lag
				   ELSE 0
			  END
			  -
			  CASE WHEN total > @base_quantity + @total_sold 
				   THEN  total - @base_quantity - @total_sold 
				   else 0 
			  END AS available, *
			FROM
			(
				  SELECT *, lag(total, 1, 0) OVER(ORDER BY id ASC) AS lag
				  FROM
				  (
					  SELECT *, SUM(base_quantity) OVER(ORDER BY id ASC) AS total 
					  FROM all_purchases
				  ) AS temp1
			) AS temp2
			WHERE lag < @base_quantity + @total_sold
		)
		SELECT @base_unit_cost = SUM(((price * quantity) / base_quantity) * (available))
		FROM details;
	END;

	IF(@method = 'LIFO')
	BEGIN
		WITH all_purchases
		AS
		(
			SELECT ROW_NUMBER() OVER(ORDER BY value_date DESC, checkout_detail_id DESC) AS id, *
			FROM inventory.verified_checkout_details_view
			WHERE item_id = @item_id
			AND store_id = @store_id
			AND transaction_type = 'Dr'
		),
		details
		AS
		(
			SELECT
			  base_quantity - 
			  CASE WHEN total < @total_sold THEN base_quantity 
				   WHEN lag < @total_sold THEN @total_sold - lag
				   ELSE 0
			  END
			  -
			  CASE WHEN total > @base_quantity + @total_sold 
				   THEN  total - @base_quantity - @total_sold 
				   else 0 
			  END AS available, *
			FROM
			(
				  SELECT *, lag(total, 1, 0) OVER(ORDER BY id ASC) AS lag
				  FROM
				  (
					  SELECT *, SUM(base_quantity) OVER(ORDER BY id ASC) AS total 
					  FROM all_purchases
				  ) AS temp1
			) AS temp2
			WHERE lag < @base_quantity + @total_sold
		)
		SELECT @base_unit_cost = SUM(((price * quantity) / base_quantity) * available)
		FROM details;
	END;

	IF(@base_unit_cost IS NULL)
	BEGIN
		SET @base_unit_cost = inventory.get_item_cost_price(@item_id, @base_unit_id) * @base_quantity;
	END;


    --APPLY numeric(30, 6) QUANTITY PROVISON
    SET @base_unit_cost = @base_unit_cost * (@backup_quantity / @base_quantity);


    RETURN @base_unit_cost;
END;




GO

--SELECT inventory.get_cost_of_goods_sold(6191, 11, 1, 1);


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.get_root_unit_id.sql --<--<--
IF OBJECT_ID('inventory.get_root_unit_id') IS NOT NULL
DROP FUNCTION inventory.get_root_unit_id;

GO

CREATE FUNCTION inventory.get_root_unit_id(@any_unit_id integer)
RETURNS integer
AS
BEGIN
    DECLARE @root_unit_id integer;

    SELECT @root_unit_id = base_unit_id
    FROM inventory.compound_units
    WHERE inventory.compound_units.compare_unit_id=@any_unit_id
    AND inventory.compound_units.deleted = 0;

    IF(@root_unit_id IS NULL OR @root_unit_id = @any_unit_id)
    BEGIN
        RETURN @any_unit_id;
    END

    RETURN inventory.get_root_unit_id(@root_unit_id);
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.post_adjustment.sql --<--<--
IF OBJECT_ID('inventory.post_adjustment') IS NOT NULL
DROP PROCEDURE inventory.post_adjustment;

GO

CREATE PROCEDURE inventory.post_adjustment
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @store_id                               integer,
    @value_date                             date,
    @book_date                              date,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @details                                inventory.adjustment_type READONLY,
    @transaction_master_id                  bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @checkout_id                    bigint;
    DECLARE @book_name                      national character varying(1000)='Inventory Adjustment';
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @default_currency_code          national character varying(12);
	DECLARE @is_positive_adjustment			bit;
    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);
	DECLARE @inventory_entry_tran_type		national character varying(12);
	DECLARE @inventory_account_tran_type	national character varying(12);
	DECLARE @cogs_tran_type					national character varying(12);

    DECLARE @temp_stock_details TABLE
    (
        tran_type                           national character varying(2),
        store_id                            integer,
        item_id                             integer,
        item_code                           national character varying(12),
        unit_id                             integer,
        base_unit_id                        integer,
        unit_name                           national character varying(50),
        quantity                            numeric(30, 6),
        base_quantity                       numeric(30, 6),                
        price                               numeric(30, 6),
        cost_of_goods_sold                  numeric(30, 6) DEFAULT(0),
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    ); 

    DECLARE @temp_transaction_details TABLE
    (
        tran_type                           national character varying(2), 
        account_id                          integer, 
        statement_reference                 national character varying(2000), 
        cash_repository_id                  integer, 
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
        
        INSERT INTO @temp_stock_details(tran_type, store_id, item_code, unit_name, quantity)
        SELECT tran_type, @store_id, item_code, unit_name, quantity 
        FROM @details;

        IF
        (
            SELECT COUNT(DISTINCT tran_type) FROM @temp_stock_details
        ) > 1
        BEGIN
            RAISERROR('This transaction cannot have both positive and negative adjustment entries.', 13, 1);
        END;

		SELECT @is_positive_adjustment = iif(tran_type = 'Dr', 1, 0)
		FROM @temp_stock_details;

        IF EXISTS
        (
            SELECT 1 FROM @temp_stock_details
            GROUP BY item_code
            HAVING COUNT(item_code) <> 1
        )
        BEGIN
            RAISERROR('An item can appear only once in a store.', 13, 1);
        END;

        UPDATE @temp_stock_details 
        SET 
            item_id         = inventory.get_item_id_by_item_code(item_code),
            unit_id         = inventory.get_unit_id_by_unit_name(unit_name);

        IF EXISTS
        (
            SELECT * FROM @temp_stock_details
            WHERE item_id IS NULL OR unit_id IS NULL OR store_id IS NULL
        )
        BEGIN
            RAISERROR('Invalid data supplied.', 13, 1);
        END;


		SET @inventory_entry_tran_type = 'Cr';
		SET @inventory_account_tran_type = 'Cr';
		SET @cogs_tran_type = 'Dr';

		IF(@is_positive_adjustment = 1)
		BEGIN
			SET @inventory_entry_tran_type = 'Dr';
			SET @inventory_account_tran_type = 'Dr';
			SET @cogs_tran_type = 'Cr';
		END;

        UPDATE @temp_stock_details 
        SET
            tran_type                       = @inventory_entry_tran_type,
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id),
            price                           = inventory.get_item_cost_price(item_id, unit_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id),
            cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);


        IF EXISTS
        (
            SELECT 1
            FROM 
            inventory.stores
            WHERE inventory.stores.store_id
            IN
            (
                SELECT store_id
                FROM @temp_stock_details
            )
            HAVING COUNT(DISTINCT inventory.stores.office_id) > 1
        )
        BEGIN
            RAISERROR('Access is denied!\nA stock adjustment transaction cannot references multiple branches.', 13, 1);
        END;

        IF EXISTS
        (
            SELECT 1
            FROM 
            @temp_stock_details
            WHERE tran_type = 'Cr'
            AND quantity > inventory.count_item_in_stock(item_id, unit_id, store_id)
        )
        BEGIN
            RAISERROR('Negative stock is not allowed.', 13, 1);
        END;

        --No accounting treatment is needed for periodic accounting system.
        IF(@is_periodic = 0)
        BEGIN
            SET @default_currency_code  = core.get_currency_code_by_office_id(@office_id);

            UPDATE @temp_stock_details 
            SET 
                cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);
        
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT @cogs_tran_type, cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM @temp_stock_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT @inventory_account_tran_type, inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM @temp_stock_details
            GROUP BY inventory_account_id;
        END;
        
        INSERT INTO finance.transaction_master
        (
            transaction_counter,
            transaction_code,
            book,
            value_date,
            book_date,
            login_id,
            user_id,
            office_id,
            reference_number,
            statement_reference
        )
        SELECT
            finance.get_new_transaction_counter(@value_date), 
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book_name,
            @value_date,
            @book_date,
            @login_id,
            @user_id,
            @office_id,
            @reference_number,
            @statement_reference;

        SET @transaction_master_id = SCOPE_IDENTITY();

        INSERT INTO finance.transaction_details(office_id, value_date, book_date, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @office_id, @value_date, @book_date, @transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;


        INSERT INTO inventory.checkouts(transaction_master_id, value_date, book_date, transaction_book, posted_by, office_id, taxable_total, tax, nontaxable_total)
        SELECT @transaction_master_id, @value_date, @book_date, @book_name, @user_id, @office_id, 0, 0, 0;

        SET @checkout_id                = SCOPE_IDENTITY();


        INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price)
        SELECT @checkout_id, @value_date, @book_date, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price
        FROM @temp_stock_details;

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


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/02.functions-and-logic/inventory.post_transfer.sql --<--<--
IF OBJECT_ID('inventory.post_transfer') IS NOT NULL
DROP PROCEDURE inventory.post_transfer;

GO

CREATE PROCEDURE inventory.post_transfer
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @value_date                             date,
    @book_date                              date,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @details                                inventory.transfer_type READONLY,
	@transaction_master_id					bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @checkout_id                    bigint;
    DECLARE @book_name                      national character varying(1000)='Inventory Transfer';
    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);

    DECLARE @temp_stock_details TABLE
    (
        tran_type                           national character varying(2),
        store_id                            integer,
        store_name                          national character varying(500),
        item_id                             integer,
        item_code                           national character varying(24),
        unit_id                             integer,
        base_unit_id                        integer,
        unit_name                           national character varying(500),
        quantity                            numeric(30, 6),
        base_quantity                       numeric(30, 6),                
        price                               numeric(30, 6)
    ); 

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction               = can_post_transaction,
            @error_message                      = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;


        INSERT INTO @temp_stock_details(tran_type, store_name, item_code, unit_name, quantity, price)
        SELECT tran_type, store_name, item_code, unit_name, quantity, rate
        FROM @details;

        IF EXISTS
        (
            SELECT 1 FROM @temp_stock_details
            GROUP BY item_code, store_name
            HAVING COUNT(item_code) <> 1
        )
        BEGIN
			SET @error_message = 'An item can appear only once in a store. <br /> <br />';

            SELECT @error_message = @error_message + item_code + ' (' + CAST(COUNT(item_code) AS varchar(50)) + ') --> ' + store_name + '<br />'
            FROM @temp_stock_details
            GROUP BY item_code, store_name
            HAVING COUNT(item_code) <> 1
			ORDER BY item_code;

            RAISERROR(@error_message, 13, 1);
        END;

        UPDATE @temp_stock_details 
        SET 
            item_id         = inventory.get_item_id_by_item_code(item_code),
            unit_id         = inventory.get_unit_id_by_unit_name(unit_name),
            store_id        = inventory.get_store_id_by_store_name(store_name);

        IF EXISTS
        (
            SELECT * FROM @temp_stock_details
            WHERE item_id IS NULL OR unit_id IS NULL OR store_id IS NULL
        )
        BEGIN
            RAISERROR('Invalid data supplied.', 13, 1);
        END;

        UPDATE @temp_stock_details 
        SET
            base_unit_id    = inventory.get_root_unit_id(unit_id),
            base_quantity   = inventory.get_base_quantity_by_unit_id(unit_id, quantity);

        UPDATE @temp_stock_details 
        SET
            price           = inventory.get_item_cost_price(item_id, unit_id)
        WHERE price IS NULL;

        IF EXISTS
        (
            SELECT item_code FROM @temp_stock_details
            GROUP BY item_code
            HAVING SUM(CASE WHEN tran_type='Dr' THEN base_quantity ELSE base_quantity *-1 END) <> 0
        )
        BEGIN
            RAISERROR('Referencing sides are not equal.', 13, 1);
        END;


        IF EXISTS
        (
            SELECT 1
            FROM 
            inventory.stores
            WHERE inventory.stores.store_id
            IN
            (
                SELECT store_id
                FROM @temp_stock_details
            )
            HAVING COUNT(DISTINCT inventory.stores.office_id) > 1
        )
        BEGIN
            RAISERROR('Access is denied!\nA stock journal transaction cannot references multiple branches.', 13, 1);
        END;

        IF EXISTS
        (
            SELECT 1
            FROM 
            @temp_stock_details
            WHERE tran_type = 'Cr'
            AND quantity > inventory.count_item_in_stock(item_id, unit_id, store_id)
        )
        BEGIN
			SET @error_message = 'Negative stock is not allowed. <br /> <br />';

            SELECT @error_message = @error_message + inventory.get_item_name_by_item_id(item_id) + ' --> required: ' + CAST(quantity AS varchar(50))+ ', actual: ' + CAST(inventory.count_item_in_stock(item_id, unit_id, store_id)  AS varchar(50)) + ' / ' + inventory.get_unit_name_by_unit_id(unit_id) +  ' <br />'
            FROM 
            @temp_stock_details
            WHERE tran_type = 'Cr'
            AND quantity > inventory.count_item_in_stock(item_id, unit_id, store_id);

            RAISERROR(@error_message, 13, 1);
        END;

        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, reference_number, statement_reference)
        SELECT
            finance.get_new_transaction_counter(@value_date), 
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book_name,
            @value_date,
            @book_date,
            @login_id,
            @user_id,
            @office_id,
            @reference_number,
            @statement_reference;

        SET @transaction_master_id = SCOPE_IDENTITY();

        INSERT INTO inventory.checkouts(transaction_master_id, transaction_book, value_date, book_date, posted_by, office_id, taxable_total, discount, tax_rate, tax, nontaxable_total)
        SELECT @transaction_master_id, @book_name, @value_date, @book_date, @user_id, @office_id, 1, 0, 0, 0, 0;
        SET @checkout_id                = SCOPE_IDENTITY();

        INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price)
        SELECT @checkout_id, @value_date, @book_date, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price
        FROM @temp_stock_details;
        
        
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



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/03.menus/menus.sql --<--<--
EXECUTE core.create_menu 'MixERP.Inventory', 'InventorySetup','Inventory Setup', '/dashboard/inventory/setup/is', 'child', 'Setup';
EXECUTE core.create_menu 'MixERP.Inventory', 'TransactionDetails', 'Transaction Details', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/TransactionDetails.xml', 'map signs', 'Reports';

DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'MixERP.Inventory',
'{*}';


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.scrud-views/inventory.compound_unit_scrud_view.sql --<--<--
IF OBJECT_ID('inventory.compound_unit_scrud_view') IS NOT NULL
DROP VIEW inventory.compound_unit_scrud_view;

GO

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

GO

-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.scrud-views/inventory.customer_scrud_view.sql --<--<--
IF OBJECT_ID('inventory.customer_scrud_view') IS NOT NULL
DROP VIEW inventory.customer_scrud_view;

GO



CREATE VIEW inventory.customer_scrud_view
AS
SELECT
    inventory.customers.customer_id,
    inventory.customers.customer_code,
    inventory.customers.customer_name,
    inventory.customer_types.customer_type_code + ' (' + inventory.customer_types.customer_type_name + ')' AS customer_type,
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


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.scrud-views/inventory.item_scrud_view.sql --<--<--
IF OBJECT_ID('inventory.item_scrud_view') IS NOT NULL
DROP VIEW inventory.item_scrud_view;

GO



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
WHERE inventory.items.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.adjustment_search_view.sql --<--<--
IF OBJECT_ID('inventory.adjustment_search_view') IS NOT NULL
DROP VIEW inventory.adjustment_search_view;

GO

CREATE VIEW inventory.adjustment_search_view
AS
SELECT
	finance.transaction_master.book,
	finance.transaction_master.transaction_master_id AS tran_id,
	finance.transaction_master.transaction_code AS tran_code,
	SUM(inventory.checkout_details.price * inventory.checkout_details.quantity) AS amount,
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
FROM inventory.checkouts
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN inventory.checkout_details
ON inventory.checkout_details.checkout_id = inventory.checkouts.checkout_id
WHERE finance.transaction_master.deleted = 0
AND finance.transaction_master.book = 'Inventory Adjustment'
GROUP BY
finance.transaction_master.book,
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_code,
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


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.checkout_detail_view.sql --<--<--
IF OBJECT_ID('inventory.checkout_detail_view') IS NOT NULL
DROP VIEW inventory.checkout_detail_view;

GO



CREATE VIEW inventory.checkout_detail_view
AS
SELECT
    inventory.checkouts.transaction_master_id,
    inventory.checkouts.checkout_id,
    inventory.checkout_details.checkout_detail_id,
    inventory.checkout_details.transaction_type,
    inventory.checkout_details.store_id,
    inventory.stores.store_code,
    inventory.stores.store_name,
    inventory.checkout_details.item_id,
    inventory.items.is_taxable_item,
    inventory.items.item_code,
    inventory.items.item_name,
    inventory.checkout_details.quantity,
    inventory.checkout_details.unit_id,
    inventory.units.unit_code,
    inventory.units.unit_name,
    inventory.checkout_details.base_quantity,
    inventory.checkout_details.base_unit_id,
    base_unit.unit_code AS base_unit_code,
    base_unit.unit_name AS base_unit_name,
    inventory.checkout_details.cost_of_goods_sold,
    inventory.checkout_details.price,
    inventory.checkout_details.discount,
    inventory.checkout_details.shipping_charge,
    (inventory.checkout_details.price * inventory.checkout_details.quantity) 
    + COALESCE(inventory.checkout_details.shipping_charge, 0)
    - COALESCE(inventory.checkout_details.discount, 0) AS amount,
    (inventory.checkout_details.price * inventory.checkout_details.quantity) 
    + COALESCE(inventory.checkout_details.shipping_charge, 0)
    - COALESCE(inventory.checkout_details.discount, 0) AS total
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN inventory.stores
ON inventory.stores.store_id = inventory.checkout_details.store_id
INNER JOIN inventory.items
ON inventory.items.item_id = inventory.checkout_details.item_id
INNER JOIN inventory.units
ON inventory.units.unit_id = inventory.checkout_details.unit_id
INNER JOIN inventory.units AS base_unit
ON base_unit.unit_id = inventory.checkout_details.base_unit_id;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.checkout_view.sql --<--<--
IF OBJECT_ID('inventory.checkout_view') IS NOT NULL
DROP VIEW inventory.checkout_view-- CASCADE;

GO



CREATE VIEW inventory.checkout_view
AS
SELECT
    finance.transaction_master.transaction_master_id,
    inventory.checkouts.checkout_id,
    inventory.checkout_details.checkout_detail_id,
    finance.transaction_master.book,
    finance.transaction_master.transaction_counter,
    finance.transaction_master.transaction_code,
    finance.transaction_master.value_date,
    finance.transaction_master.transaction_ts,
    finance.transaction_master.login_id,
    finance.transaction_master.user_id,
    finance.transaction_master.office_id,
    finance.transaction_master.cost_center_id,
    finance.transaction_master.reference_number,
    finance.transaction_master.statement_reference,
    finance.transaction_master.last_verified_on,
    finance.transaction_master.verified_by_user_id,
    finance.transaction_master.verification_status_id,
    finance.transaction_master.verification_reason,
    inventory.checkout_details.transaction_type,
    inventory.checkout_details.store_id,
    inventory.checkout_details.item_id,
    inventory.checkout_details.quantity,
    inventory.checkout_details.unit_id,
    inventory.checkout_details.base_quantity,
    inventory.checkout_details.base_unit_id,
    inventory.checkout_details.price,
    inventory.checkout_details.discount,
    inventory.checkout_details.shipping_charge,
    (
        inventory.checkout_details.price 
        - inventory.checkout_details.discount 
        + COALESCE(inventory.checkout_details.shipping_charge, 0)
    ) * inventory.checkout_details.quantity AS amount
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.item_view.sql --<--<--
IF OBJECT_ID('inventory.item_view') IS NOT NULL
DROP VIEW inventory.item_view;

GO



CREATE VIEW inventory.item_view
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
    inventory.items.cost_price,
    inventory.items.cost_price_includes_tax,
    inventory.items.selling_price,
    inventory.items.selling_price_includes_tax,
    inventory.items.photo,
    inventory.items.maintain_inventory
FROM inventory.items
INNER JOIN inventory.item_groups
ON inventory.item_groups.item_group_id = inventory.items.item_group_id
INNER JOIN inventory.item_types
ON inventory.item_types.item_type_id = inventory.items.item_type_id
LEFT JOIN inventory.brands
ON inventory.brands.brand_id = inventory.items.brand_id
INNER JOIN inventory.units
ON inventory.units.unit_id = inventory.items.unit_id
WHERE inventory.items.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.serial_numbers_view.sql --<--<--
IF OBJECT_ID('inventory.serial_numbers_view') IS NOT NULL
DROP VIEW inventory.serial_numbers_view;
GO

CREATE VIEW inventory.serial_numbers_view
AS
SELECT 
    serial_numbers.serial_number_id,
    serial_numbers.item_id,
    items.item_name,
    serial_numbers.unit_id,
    units.unit_code,
    serial_numbers.store_id,
    stores.store_name,
    serial_numbers.transaction_type,
    serial_numbers.checkout_id,
    checkouts.transaction_master_id,
    serial_numbers.batch_number,
    serial_numbers.serial_number,
    serial_numbers.expiry_date,
	CASE WHEN COALESCE(transaction_master.verification_status_id, 0) >= 0 THEN
		serial_numbers.sales_transaction_id END AS sales_transaction_id
FROM inventory.serial_numbers
JOIN inventory.items ON serial_numbers.item_id = items.item_id
JOIN inventory.units ON serial_numbers.unit_id = units.unit_id
JOIN inventory.stores ON serial_numbers.store_id = stores.store_id
JOIN inventory.checkouts ON serial_numbers.checkout_id = checkouts.checkout_id
LEFT JOIN finance.transaction_master ON serial_numbers.sales_transaction_id = transaction_master.transaction_master_id
WHERE serial_numbers.deleted = 0
GO



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.transaction_view.sql --<--<--
IF OBJECT_ID('inventory.transaction_view') IS NOT NULL
DROP VIEW inventory.transaction_view;

GO

CREATE VIEW inventory.transaction_view 
AS
SELECT 
    checkouts.checkout_id,
    checkouts.value_date,
    checkouts.transaction_master_id,
    checkouts.transaction_book,
    checkouts.office_id,
    checkout_details.store_id,
    checkout_details.transaction_type,
    checkout_details.item_id,
    checkout_details.price,
    checkout_details.discount,
    checkout_details.cost_of_goods_sold,
    checkouts.shipper_id,
    checkout_details.shipping_charge,
    checkout_details.unit_id,
    checkout_details.quantity
FROM inventory.checkouts
JOIN inventory.checkout_details ON checkouts.checkout_id = checkout_details.checkout_id
JOIN finance.transaction_master ON checkouts.transaction_master_id = transaction_master.transaction_master_id
WHERE checkouts.cancelled = 0
AND checkouts.deleted = 0
AND transaction_master.verification_status_id > 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.transfer_search_view.sql --<--<--
IF OBJECT_ID('inventory.transfer_search_view') IS NOT NULL
DROP VIEW inventory.transfer_search_view;

GO

CREATE VIEW inventory.transfer_search_view
AS
SELECT
	finance.transaction_master.transaction_master_id AS tran_id,
	finance.transaction_master.book,
	finance.transaction_master.transaction_code AS tran_code,
	SUM(inventory.checkout_details.price * inventory.checkout_details.quantity) AS amount,
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
FROM inventory.checkouts
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN inventory.checkout_details
ON inventory.checkout_details.checkout_id = inventory.checkouts.checkout_id
WHERE finance.transaction_master.deleted = 0
AND finance.transaction_master.book = 'Inventory Transfer'
GROUP BY
finance.transaction_master.book,
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_code,
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


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.verified_checkout_details_view.sql --<--<--
IF OBJECT_ID('inventory.verified_checkout_details_view') IS NOT NULL
DROP VIEW inventory.verified_checkout_details_view;

GO



CREATE VIEW inventory.verified_checkout_details_view
AS
SELECT inventory.checkout_details.* 
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
AND finance.transaction_master.verification_status_id > 0;


GO



-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/05.views/inventory.verified_checkout_view.sql --<--<--
IF OBJECT_ID('inventory.verified_checkout_view') IS NOT NULL
DROP VIEW inventory.verified_checkout_view;

GO

CREATE VIEW inventory.verified_checkout_view
AS
SELECT * FROM inventory.checkout_view
WHERE verification_status_id > 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.1.update/src/99.ownership.sql --<--<--
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

