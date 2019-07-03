DROP FUNCTION IF EXISTS sales.refresh_materialized_views(_user_id integer, _login_id bigint, _office_id integer, _value_date date);

CREATE FUNCTION sales.refresh_materialized_views(_user_id integer, _login_id bigint, _office_id integer, _value_date date)
RETURNS void
AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW finance.trial_balance_view;
    REFRESH MATERIALIZED VIEW inventory.verified_checkout_view;
    REFRESH MATERIALIZED VIEW finance.verified_transaction_mat_view;
    REFRESH MATERIALIZED VIEW finance.verified_cash_transaction_mat_view;
END
$$
LANGUAGE plpgsql;


SELECT finance.create_routine('REF-MV', 'sales.refresh_materialized_views', 9999);

--SELECT * FROM sales.refresh_materialized_views(1, 1, 1, '1-1-2000')