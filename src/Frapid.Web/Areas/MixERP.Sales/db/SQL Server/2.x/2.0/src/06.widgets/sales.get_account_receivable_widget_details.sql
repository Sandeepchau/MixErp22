IF OBJECT_ID('sales.get_account_receivable_widget_details') IS NOT NULL
DROP FUNCTION sales.get_account_receivable_widget_details;
GO

CREATE FUNCTION sales.get_account_receivable_widget_details(@office_id integer)
RETURNS @result TABLE
(
    all_time_sales                              numeric(30, 6),
    all_time_receipt                            numeric(30, 6),
    receivable_of_all_time                      numeric(30, 6),
    this_months_sales                           numeric(30, 6),
    this_months_receipt                         numeric(30, 6),
    receivable_of_this_month                    numeric(30, 6)
)
AS
BEGIN
    DECLARE @all_time_sales                     numeric(30, 6);
    DECLARE @all_time_receipt                   numeric(30, 6);
    DECLARE @this_months_sales                  numeric(30, 6);
    DECLARE @this_months_receipt                numeric(30, 6);
    DECLARE @start_date                         date = finance.get_month_start_date(@office_id);
    DECLARE @end_date                           date = finance.get_month_end_date(@office_id);

    SELECT @all_time_sales = COALESCE(SUM(sales.sales.total_amount), 0) 
    FROM sales.sales
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND finance.transaction_master.verification_status_id > 0;
    
    SELECT @all_time_receipt = COALESCE(SUM(sales.customer_receipts.amount), 0)
    FROM sales.customer_receipts
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.customer_receipts.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND finance.transaction_master.verification_status_id > 0;

    SELECT @this_months_sales = COALESCE(SUM(sales.sales.total_amount), 0)
    FROM sales.sales
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date BETWEEN @start_date AND @end_date;
    
    SELECT @this_months_receipt = COALESCE(SUM(sales.customer_receipts.amount), 0) 
    FROM sales.customer_receipts
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.customer_receipts.transaction_master_id
    WHERE finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date BETWEEN @start_date AND @end_date;

	INSERT INTO @result
    SELECT @all_time_sales, @all_time_receipt, @all_time_sales - @all_time_receipt, 
    @this_months_sales, @this_months_receipt, @this_months_sales - @this_months_receipt;

	RETURN;
END

GO

--SELECT * FROM sales.get_account_receivable_widget_details(1);

