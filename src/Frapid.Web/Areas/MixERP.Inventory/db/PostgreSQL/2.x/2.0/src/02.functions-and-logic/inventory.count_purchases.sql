DROP FUNCTION IF EXISTS inventory.count_purchases(_item_id integer, _unit_id integer, _store_id integer);

CREATE FUNCTION inventory.count_purchases(_item_id integer, _unit_id integer, _store_id integer)
RETURNS numeric(30, 6)
STABLE
AS
$$
    DECLARE _base_unit_id integer;
    DECLARE _debit numeric(30, 6);
    DECLARE _factor numeric(30, 6);
BEGIN
    --Get the base item unit
    SELECT 
        inventory.get_root_unit_id(inventory.items.unit_id) 
    INTO _base_unit_id
    FROM inventory.items
    WHERE inventory.items.item_id=$1
	AND NOT inventory.items.deleted;

    SELECT
        COALESCE(SUM(base_quantity), 0)
    INTO _debit
    FROM inventory.checkout_details
    INNER JOIN inventory.checkouts
    ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND inventory.checkout_details.item_id=$1
    AND inventory.checkout_details.store_id=$3
    AND inventory.checkout_details.transaction_type='Dr';

    _factor = inventory.convert_unit(_base_unit_id, $2);    
    RETURN _debit * _factor;
END
$$
LANGUAGE plpgsql;

