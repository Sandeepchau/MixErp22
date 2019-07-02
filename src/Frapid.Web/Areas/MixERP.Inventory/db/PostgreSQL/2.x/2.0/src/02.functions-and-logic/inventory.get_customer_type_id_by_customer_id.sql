DROP FUNCTION IF EXISTS inventory.get_customer_type_id_by_customer_id(_customer_id integer);

CREATE FUNCTION inventory.get_customer_type_id_by_customer_id(_customer_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.customers.customer_type_id
    FROM inventory.customers
    WHERE inventory.customers.customer_id = _customer_id
    AND NOT inventory.customers.deleted;
END
$$
LANGUAGE plpgsql;
