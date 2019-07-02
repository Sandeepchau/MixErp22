IF OBJECT_ID('inventory.verified_checkout_view') IS NOT NULL
DROP VIEW inventory.verified_checkout_view;

GO

CREATE VIEW inventory.verified_checkout_view
AS
SELECT * FROM inventory.checkout_view
WHERE verification_status_id > 0;

GO
