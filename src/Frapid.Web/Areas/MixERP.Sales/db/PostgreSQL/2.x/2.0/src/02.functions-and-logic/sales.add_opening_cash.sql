DROP FUNCTION IF EXISTS sales.add_opening_cash
(
	_user_id								integer,
	_transaction_date						TIMESTAMP,
	_amount									numeric(30, 6),
	_provided_by							national character varying(1000),
	_memo									national character varying(4000)
);

CREATE FUNCTION sales.add_opening_cash
(
	_user_id								integer,
	_transaction_date						TIMESTAMP,
	_amount									numeric(30, 6),
	_provided_by							national character varying(1000),
	_memo									national character varying(4000)
)
RETURNS void
AS
$$
BEGIN
	IF NOT EXISTS
	(
		SELECT 1
		FROM sales.opening_cash
		WHERE user_id = _user_id
		AND transaction_date = _transaction_date
	) THEN
		INSERT INTO sales.opening_cash(user_id, transaction_date, amount, provided_by, memo, audit_user_id, audit_ts, deleted)
		SELECT _user_id, _transaction_date, _amount, _provided_by, _memo, _user_id, NOW(), false;
	ELSE
		UPDATE sales.opening_cash
		SET
			amount = _amount,
			provided_by = _provided_by,
			memo = _memo,
			user_id = _user_id,
			audit_user_id = _user_id,
			audit_ts = NOW(),
			deleted = false
		WHERE user_id = _user_id
		AND transaction_date = _transaction_date;
	END IF;
END
$$
LANGUAGE plpgsql;