DROP VIEW IF EXISTS sales.sales_view;

CREATE VIEW sales.sales_view
AS
SELECT
    sales.sales.sales_id,
    sales.sales.transaction_master_id,
    finance.transaction_master.transaction_code,
    finance.transaction_master.transaction_counter,
    finance.transaction_master.value_date,
    finance.transaction_master.book_date,
	inventory.checkouts.nontaxable_total,
	inventory.checkouts.taxable_total,
    inventory.checkouts.tax_rate,
    inventory.checkouts.tax,
	inventory.checkouts.discount,
    finance.transaction_master.transaction_ts,
    finance.transaction_master.verification_status_id,
    core.verification_statuses.verification_status_name,
    finance.transaction_master.verified_by_user_id,
    account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) AS verified_by,
    sales.sales.checkout_id,
    inventory.checkouts.posted_by,
    account.get_name_by_user_id(inventory.checkouts.posted_by) AS posted_by_name,
    inventory.checkouts.office_id,
    inventory.checkouts.cancelled,
    inventory.checkouts.cancellation_reason,    
    sales.sales.cash_repository_id,
    finance.cash_repositories.cash_repository_code,
    finance.cash_repositories.cash_repository_name,
    sales.sales.price_type_id,
    sales.price_types.price_type_code,
    sales.price_types.price_type_name,
    sales.sales.counter_id,
    inventory.counters.counter_code,
    inventory.counters.counter_name,
    inventory.counters.store_id,
    inventory.stores.store_code,
    inventory.stores.store_name,
    sales.sales.customer_id,
    inventory.customers.customer_name,
    sales.sales.salesperson_id,
    account.get_name_by_user_id(sales.sales.salesperson_id) as salesperson_name,
    sales.sales.gift_card_id,
    sales.gift_cards.gift_card_number,
    sales.gift_cards.first_name || ' ' || sales.gift_cards.middle_name || ' ' || sales.gift_cards.last_name AS gift_card_owner,
    sales.sales.coupon_id,
    sales.coupons.coupon_code,
    sales.coupons.coupon_name,
    sales.sales.is_flat_discount,
    sales.sales.total_discount_amount,
    sales.sales.is_credit,
    sales.sales.payment_term_id,
    sales.payment_terms.payment_term_code,
    sales.payment_terms.payment_term_name,
    sales.sales.fiscal_year_code,
    sales.sales.invoice_number,
    sales.sales.total_amount,
    sales.sales.tender,
    sales.sales.change,
    sales.sales.check_number,
    sales.sales.check_date,
    sales.sales.check_bank_name,
    sales.sales.check_amount,
    sales.sales.reward_points
FROM sales.sales
INNER JOIN inventory.checkouts
ON inventory.checkouts.checkout_id = sales.sales.checkout_id
INNER JOIN finance.transaction_master
ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
INNER JOIN finance.cash_repositories
ON finance.cash_repositories.cash_repository_id = sales.sales.cash_repository_id
INNER JOIN sales.price_types
ON sales.price_types.price_type_id = sales.sales.price_type_id
INNER JOIN inventory.counters
ON inventory.counters.counter_id = sales.sales.counter_id
INNER JOIN inventory.stores
ON inventory.stores.store_id = inventory.counters.store_id
INNER JOIN inventory.customers
ON inventory.customers.customer_id = sales.sales.customer_id
LEFT JOIN sales.gift_cards
ON sales.gift_cards.gift_card_id = sales.sales.gift_card_id
LEFT JOIN sales.payment_terms
ON sales.payment_terms.payment_term_id = sales.sales.payment_term_id
LEFT JOIN sales.coupons
ON sales.coupons.coupon_id = sales.sales.coupon_id
LEFT JOIN core.verification_statuses
ON core.verification_statuses.verification_status_id = finance.transaction_master.verification_status_id
WHERE NOT finance.transaction_master.deleted;


--SELECT * FROM sales.sales_view