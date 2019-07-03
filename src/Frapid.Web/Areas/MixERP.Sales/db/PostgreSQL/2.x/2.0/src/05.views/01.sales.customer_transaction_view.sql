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