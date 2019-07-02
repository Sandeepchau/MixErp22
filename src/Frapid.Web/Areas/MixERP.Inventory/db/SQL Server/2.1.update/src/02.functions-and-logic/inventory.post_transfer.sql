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

