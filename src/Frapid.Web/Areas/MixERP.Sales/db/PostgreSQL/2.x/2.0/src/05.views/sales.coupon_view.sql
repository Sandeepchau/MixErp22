DROP VIEW IF EXISTS sales.coupon_view;

CREATE VIEW sales.coupon_view
AS
SELECT
    sales.coupons.coupon_id,
    sales.coupons.coupon_code,
    sales.coupons.coupon_name,
    sales.coupons.discount_rate,
    sales.coupons.is_percentage,
    sales.coupons.maximum_discount_amount,
    sales.coupons.associated_price_type_id,
    associated_price_type.price_type_code AS associated_price_type_code,
    associated_price_type.price_type_name AS associated_price_type_name,
    sales.coupons.minimum_purchase_amount,
    sales.coupons.maximum_purchase_amount,
    sales.coupons.begins_from,
    sales.coupons.expires_on,
    sales.coupons.maximum_usage,
    sales.coupons.enable_ticket_printing,
    sales.coupons.for_ticket_of_price_type_id,
    for_ticket_of_price_type.price_type_code AS for_ticket_of_price_type_code,
    for_ticket_of_price_type.price_type_name AS for_ticket_of_price_type_name,
    sales.coupons.for_ticket_having_minimum_amount,
    sales.coupons.for_ticket_having_maximum_amount,
    sales.coupons.for_ticket_of_unknown_customers_only
FROM sales.coupons
LEFT JOIN sales.price_types AS associated_price_type
ON associated_price_type.price_type_id = sales.coupons.associated_price_type_id
LEFT JOIN sales.price_types AS for_ticket_of_price_type
ON for_ticket_of_price_type.price_type_id = sales.coupons.for_ticket_of_price_type_id;

