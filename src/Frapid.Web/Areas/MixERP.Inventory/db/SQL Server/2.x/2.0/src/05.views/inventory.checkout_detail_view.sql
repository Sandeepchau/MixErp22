IF OBJECT_ID('inventory.checkout_detail_view') IS NOT NULL
DROP VIEW inventory.checkout_detail_view;

GO



CREATE VIEW inventory.checkout_detail_view
AS
SELECT
    inventory.checkouts.transaction_master_id,
    inventory.checkouts.checkout_id,
    inventory.checkout_details.checkout_detail_id,
    inventory.checkout_details.transaction_type,
    inventory.checkout_details.store_id,
    inventory.stores.store_code,
    inventory.stores.store_name,
    inventory.checkout_details.item_id,
    inventory.items.is_taxable_item,
    inventory.items.item_code,
    inventory.items.item_name,
    inventory.checkout_details.quantity,
    inventory.checkout_details.unit_id,
    inventory.units.unit_code,
    inventory.units.unit_name,
    inventory.checkout_details.base_quantity,
    inventory.checkout_details.base_unit_id,
    base_unit.unit_code AS base_unit_code,
    base_unit.unit_name AS base_unit_name,
    inventory.checkout_details.price,
    inventory.checkout_details.discount,
    inventory.checkout_details.shipping_charge,
    (inventory.checkout_details.price * inventory.checkout_details.quantity) 
    + COALESCE(inventory.checkout_details.shipping_charge, 0)
    - COALESCE(inventory.checkout_details.discount, 0) AS amount,
    (inventory.checkout_details.price * inventory.checkout_details.quantity) 
    + COALESCE(inventory.checkout_details.shipping_charge, 0)
    - COALESCE(inventory.checkout_details.discount, 0) AS total
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN inventory.stores
ON inventory.stores.store_id = inventory.checkout_details.store_id
INNER JOIN inventory.items
ON inventory.items.item_id = inventory.checkout_details.item_id
INNER JOIN inventory.units
ON inventory.units.unit_id = inventory.checkout_details.unit_id
INNER JOIN inventory.units AS base_unit
ON base_unit.unit_id = inventory.checkout_details.base_unit_id;


GO
