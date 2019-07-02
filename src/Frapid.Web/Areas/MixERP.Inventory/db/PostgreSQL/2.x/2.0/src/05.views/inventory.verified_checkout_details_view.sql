DROP VIEW IF EXISTS inventory.verified_checkout_details_view;

CREATE VIEW inventory.verified_checkout_details_view
AS
SELECT inventory.checkout_details.*
FROM inventory.checkout_details
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
AND finance.transaction_master.verification_status_id > 0;
