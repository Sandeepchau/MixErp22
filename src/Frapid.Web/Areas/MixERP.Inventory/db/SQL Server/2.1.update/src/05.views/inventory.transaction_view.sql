IF OBJECT_ID('inventory.transaction_view') IS NOT NULL
DROP VIEW inventory.transaction_view;

GO

CREATE VIEW inventory.transaction_view 
AS
SELECT 
    checkouts.checkout_id,
    checkouts.value_date,
    checkouts.transaction_master_id,
    checkouts.transaction_book,
    checkouts.office_id,
    checkout_details.store_id,
    checkout_details.transaction_type,
    checkout_details.item_id,
    checkout_details.price,
    checkout_details.discount,
    checkout_details.cost_of_goods_sold,
    checkouts.shipper_id,
    checkout_details.shipping_charge,
    checkout_details.unit_id,
    checkout_details.quantity
FROM inventory.checkouts
JOIN inventory.checkout_details ON checkouts.checkout_id = checkout_details.checkout_id
JOIN finance.transaction_master ON checkouts.transaction_master_id = transaction_master.transaction_master_id
WHERE checkouts.cancelled = 0
AND checkouts.deleted = 0
AND transaction_master.verification_status_id > 0;

GO
