IF OBJECT_ID('inventory.top_customers_by_office_view') IS NOT NULL
DROP VIEW inventory.top_customers_by_office_view;

GO

CREATE VIEW inventory.top_customers_by_office_view
AS
SELECT TOP 5
    inventory.checkouts.office_id,
    sales.sales.customer_id,
    CASE WHEN COALESCE(inventory.customers.customer_name, '') = ''
    THEN inventory.customers.company_name
    ELSE inventory.customers.customer_name
    END as customer,
    inventory.customers.company_country AS country,
    SUM
    (
        COALESCE(inventory.checkouts.taxable_total, 0) +
        COALESCE(inventory.checkouts.nontaxable_total, 0) +
        COALESCE(inventory.checkouts.tax, 0) -
        COALESCE(inventory.checkouts.discount, 0)
    ) AS amount
FROM inventory.checkouts
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN sales.sales
ON sales.sales.checkout_id = inventory.checkouts.checkout_id
INNER JOIN inventory.customers
ON sales.sales.customer_id = inventory.customers.customer_id
AND finance.transaction_master.verification_status_id > 0
GROUP BY
    inventory.checkouts.office_id,
    sales.sales.customer_id,
    inventory.customers.customer_name,
    inventory.customers.company_name,
    inventory.customers.company_country
ORDER BY 5 DESC;

GO
