DROP VIEW IF EXISTS sales.item_selling_price_scrud_view;

CREATE VIEW sales.item_selling_price_scrud_view
AS
SELECT 
    sales.item_selling_prices.item_selling_price_id,
    inventory.items.item_code || ' (' || inventory.items.item_name || ')' AS item,
    inventory.units.unit_code || ' (' || inventory.units.unit_name || ')' AS unit,
    inventory.customer_types.customer_type_code || ' (' || inventory.customer_types.customer_type_name || ')' AS customer_type,
    sales.price_types.price_type_code || ' (' || sales.price_types.price_type_name || ')' AS price_type,
    sales.item_selling_prices.includes_tax,
    sales.item_selling_prices.price
FROM sales.item_selling_prices
INNER JOIN inventory.items
ON inventory.items.item_id = sales.item_selling_prices.item_id
INNER JOIN inventory.units
ON inventory.units.unit_id = sales.item_selling_prices.unit_id
INNER JOIN inventory.customer_types
ON inventory.customer_types.customer_type_id = sales.item_selling_prices.customer_type_id
INNER JOIN sales.price_types
ON sales.price_types.price_type_id = sales.item_selling_prices.price_type_id
WHERE NOT sales.item_selling_prices.deleted;
