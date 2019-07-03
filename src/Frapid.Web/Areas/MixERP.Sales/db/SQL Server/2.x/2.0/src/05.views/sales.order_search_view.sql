IF OBJECT_ID('sales.order_search_view') IS NOT NULL
DROP VIEW sales.order_search_view;

GO

CREATE VIEW sales.order_search_view
AS
SELECT
	sales.orders.order_id,
	inventory.get_customer_name_by_customer_id(sales.orders.customer_id) AS customer,
	sales.orders.value_date,
	sales.orders.expected_delivery_date AS expected_date,
	COALESCE(sales.orders.taxable_total, 0) + 
	COALESCE(sales.orders.tax, 0) + 
	COALESCE(sales.orders.nontaxable_total, 0) - 
	COALESCE(sales.orders.discount, 0) AS total_amount,
	COALESCE(sales.orders.reference_number, '') AS reference_number,
	COALESCE(sales.orders.terms, '') AS terms,
	COALESCE(sales.orders.internal_memo, '') AS memo,
	account.get_name_by_user_id(sales.orders.user_id) AS posted_by,
	core.get_office_name_by_office_id(sales.orders.office_id) AS office,
	sales.orders.transaction_timestamp AS posted_on,
	sales.orders.office_id,
	sales.orders.discount,
	sales.orders.tax,
	sales.orders.cancelled
FROM sales.orders;

GO
