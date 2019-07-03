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