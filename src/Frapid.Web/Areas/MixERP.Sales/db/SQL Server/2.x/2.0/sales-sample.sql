-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/SQL Server/2.x/2.0/src/99.sample-data/sample.sample.sql --<--<--
INSERT INTO sales.late_fee(late_fee_code, late_fee_name, is_flat_amount, rate, account_id)
SELECT '15F', '15% fine', 0, 15, finance.get_account_id_by_account_number('30300');


INSERT INTO sales.price_types(price_type_code, price_type_name)
SELECT 'RET', 'Retail'      UNION ALL
SELECT 'WHO', 'Wholesale';

INSERT INTO sales.payment_terms(payment_term_code, payment_term_name, due_on_date, due_days, grace_period, late_fee_id)
SELECT '07DC', '7 day credit', 1,    7, 5, sales.get_late_fee_id_by_late_fee_code('15F') UNION ALL
SELECT '15DC', '15 day credit', 1,   30, 5, sales.get_late_fee_id_by_late_fee_code('15F') UNION ALL
SELECT '30DC', '30 day credit', 1,   30, 7, sales.get_late_fee_id_by_late_fee_code('15F');

INSERT INTO sales.gift_cards(gift_card_number, payable_account_id, first_name, middle_name, last_name)
SELECT '123456', finance.get_account_id_by_account_number('20100'), 'John', '', 'Doe';


INSERT INTO sales.coupons(coupon_name, coupon_code, discount_rate, is_percentage, maximum_discount_amount, minimum_purchase_amount, begins_from, expires_on, maximum_usage, enable_ticket_printing, for_ticket_having_minimum_amount, for_ticket_having_maximum_amount, for_ticket_of_unknown_customers_only)
SELECT 'Christmas Coupon', 'MERRY-XMAS', 20, 1, 5, 10, CAST(GETUTCDATE() AS date), NULL, 10, 1, 10, NULL, 0;

GO


