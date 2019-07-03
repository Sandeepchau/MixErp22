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

