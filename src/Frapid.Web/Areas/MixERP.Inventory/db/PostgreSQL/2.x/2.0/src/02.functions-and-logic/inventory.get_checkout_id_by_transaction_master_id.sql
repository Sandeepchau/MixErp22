DROP FUNCTION IF EXISTS inventory.get_checkout_id_by_transaction_master_id(_checkout_id bigint);

CREATE FUNCTION inventory.get_checkout_id_by_transaction_master_id(_checkout_id bigint)
RETURNS bigint
AS
$$
BEGIN
        RETURN
        (
            SELECT inventory.checkouts.checkout_id
            FROM inventory.checkouts
            WHERE inventory.checkouts.transaction_master_id=$1
        );
END
$$
LANGUAGE plpgsql;
