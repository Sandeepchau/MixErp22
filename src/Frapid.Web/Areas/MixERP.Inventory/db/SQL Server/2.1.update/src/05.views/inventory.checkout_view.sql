IF OBJECT_ID('inventory.checkout_view') IS NOT NULL
DROP VIEW inventory.checkout_view-- CASCADE;

GO



CREATE VIEW inventory.checkout_view
AS
SELECT
    finance.transaction_master.transaction_master_id,
    inventory.checkouts.checkout_id,
    inventory.checkout_details.checkout_detail_id,
    finance.transaction_master.book,
    finance.transaction_master.transaction_counter,
    finance.transaction_master.transaction_code,
    finance.transaction_master.value_date,
    finance.transaction_master.transaction_ts,
    finance.transaction_master.login_id,
    finance.transaction_master.user_id,
    finance.transaction_master.office_id,
    finance.transaction_master.cost_center_id,
    finance.transaction_master.reference_number,
    finance.transaction_master.statement_reference,
    finance.transaction_master.last_verified_on,
    finance.transaction_master.verified_by_user_id,
    finance.transaction_master.verification_status_id,
    finance.transaction_master.verification_reason,
    inventory.checkout_details.transaction_type,
    inventory.checkout_details.store_id,
    inventory.checkout_details.item_id,
    inventory.checkout_details.quantity,
    inventory.checkout_details.unit_id,
    inventory.checkout_details.base_quantity,
    inventory.checkout_details.base_unit_id,
    inventory.checkout_details.price,
    inventory.checkout_details.discount,
    inventory.checkout_details.shipping_charge,
    (
        inventory.checkout_details.price 
        - inventory.checkout_details.discount 
        + COALESCE(inventory.checkout_details.shipping_charge, 0)
    ) * inventory.checkout_details.quantity AS amount
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id;




GO
