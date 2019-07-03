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
