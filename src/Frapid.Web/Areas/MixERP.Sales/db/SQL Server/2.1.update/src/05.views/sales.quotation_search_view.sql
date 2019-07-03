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
