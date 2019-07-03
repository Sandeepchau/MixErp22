DROP VIEW IF EXISTS sales.cashier_scrud_view;

CREATE VIEW sales.cashier_scrud_view
AS
SELECT
    sales.cashiers.cashier_id,
    sales.cashiers.cashier_code,
    account.users.name AS associated_user,
    inventory.counters.counter_code || ' (' || inventory.counters.counter_name || ')' AS counter,
    sales.cashiers.valid_from,
    sales.cashiers.valid_till
FROM sales.cashiers
INNER JOIN account.users
ON account.users.user_id = sales.cashiers.associated_user_id
INNER JOIN inventory.counters
ON inventory.counters.counter_id = sales.cashiers.counter_id
WHERE NOT sales.cashiers.deleted;