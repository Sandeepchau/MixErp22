DROP FUNCTION IF EXISTS inventory.get_currency_code_by_customer_id(_customer_id integer);

CREATE FUNCTION inventory.get_currency_code_by_customer_id(_customer_id integer)
RETURNS national character varying(12)
AS
$$
BEGIN
    RETURN inventory.customers.currency_code
    FROM inventory.customers
    WHERE inventory.customers.customer_id = _customer_id
    AND NOT inventory.customers.deleted;
END
$$
LANGUAGE plpgsql;