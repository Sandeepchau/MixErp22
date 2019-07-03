IF OBJECT_ID('sales.gift_card_transaction_view') IS NOT NULL
DROP VIEW sales.gift_card_transaction_view;

GO



CREATE VIEW sales.gift_card_transaction_view
AS
SELECT
finance.transaction_master.transaction_master_id,
finance.transaction_master.transaction_ts,
finance.transaction_master.transaction_code,
finance.transaction_master.value_date,
finance.transaction_master.book_date,
account.users.name AS entered_by,
sales.gift_cards.first_name + ' ' + sales.gift_cards.middle_name + ' ' + sales.gift_cards.last_name AS customer_name,
sales.gift_card_transactions.amount,
core.verification_statuses.verification_status_name AS status,
verified_by_user.name AS verified_by,
finance.transaction_master.verification_reason,
finance.transaction_master.last_verified_on,
core.offices.office_name,
finance.cost_centers.cost_center_name,
finance.transaction_master.reference_number,
finance.transaction_master.statement_reference,
account.get_name_by_user_id(finance.transaction_master.user_id) AS posted_by,
finance.transaction_master.office_id
FROM finance.transaction_master
INNER JOIN core.offices
ON finance.transaction_master.office_id = core.offices.office_id
INNER JOIN finance.cost_centers
ON finance.transaction_master.cost_center_id = finance.cost_centers.cost_center_id
INNER JOIN sales.gift_card_transactions
ON sales.gift_card_transactions.transaction_master_id = finance.transaction_master.transaction_master_id
INNER JOIN account.users
ON finance.transaction_master.user_id = account.users.user_id
LEFT JOIN sales.gift_cards
ON sales.gift_card_transactions.gift_card_id = sales.gift_cards.gift_card_id
INNER JOIN core.verification_statuses
ON finance.transaction_master.verification_status_id = core.verification_statuses.verification_status_id
LEFT JOIN account.users AS verified_by_user
ON finance.transaction_master.verified_by_user_id = verified_by_user.user_id;

--SELECT * FROM sales.gift_card_transaction_view;

GO
