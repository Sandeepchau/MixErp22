IF OBJECT_ID('inventory.customer_scrud_view') IS NOT NULL
DROP VIEW inventory.customer_scrud_view;

GO



CREATE VIEW inventory.customer_scrud_view
AS
SELECT
    inventory.customers.customer_id,
    inventory.customers.customer_code,
    inventory.customers.customer_name,
    inventory.customer_types.customer_type_code + ' (' + inventory.customer_types.customer_type_name + ')' AS customer_type,
    inventory.customers.currency_code,
    inventory.customers.company_name,
    inventory.customers.company_phone_numbers,
    inventory.customers.contact_first_name,
    inventory.customers.contact_middle_name,
    inventory.customers.contact_last_name,
    inventory.customers.contact_phone_numbers,
    inventory.customers.photo
FROM inventory.customers
INNER JOIN inventory.customer_types
ON inventory.customer_types.customer_type_id = inventory.customers.customer_type_id;


GO
