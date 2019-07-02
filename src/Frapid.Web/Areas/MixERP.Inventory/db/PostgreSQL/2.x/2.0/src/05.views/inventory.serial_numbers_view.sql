
DROP VIEW IF EXISTS inventory.serial_numbers_view;
CREATE VIEW inventory.serial_numbers_view
AS
SELECT 
    serial_numbers.serial_number_id,
    serial_numbers.item_id,
    items.item_name,
    serial_numbers.unit_id,
    units.unit_code,
    serial_numbers.store_id,
    stores.store_name,
    serial_numbers.transaction_type,
    serial_numbers.checkout_id,
    checkouts.transaction_master_id,
    serial_numbers.batch_number,
    serial_numbers.serial_number,
    serial_numbers.expiry_date,
	CASE WHEN COALESCE(transaction_master.verification_status_id, 0) >= 0 THEN
		serial_numbers.sales_transaction_id END AS sales_transaction_id
FROM inventory.serial_numbers
JOIN inventory.items ON serial_numbers.item_id = items.item_id
JOIN inventory.units ON serial_numbers.unit_id = units.unit_id
JOIN inventory.stores ON serial_numbers.store_id = stores.store_id
JOIN inventory.checkouts ON serial_numbers.checkout_id = checkouts.checkout_id
LEFT JOIN finance.transaction_master ON serial_numbers.sales_transaction_id = transaction_master.transaction_master_id
WHERE NOT serial_numbers.deleted;

