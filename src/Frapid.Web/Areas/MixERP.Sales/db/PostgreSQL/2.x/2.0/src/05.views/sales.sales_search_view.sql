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
