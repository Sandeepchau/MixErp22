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
