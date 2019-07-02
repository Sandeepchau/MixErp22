DROP MATERIALIZED VIEW IF EXISTS inventory.verified_checkout_view;

CREATE MATERIALIZED VIEW inventory.verified_checkout_view
AS
SELECT * FROM inventory.checkout_view
WHERE verification_status_id > 0;

ALTER MATERIALIZED VIEW inventory.verified_checkout_view
OWNER TO frapid_db_user;

CREATE UNIQUE INDEX verified_checkout_view_checkout_detail_id_uix
ON inventory.verified_checkout_view(checkout_detail_id);
