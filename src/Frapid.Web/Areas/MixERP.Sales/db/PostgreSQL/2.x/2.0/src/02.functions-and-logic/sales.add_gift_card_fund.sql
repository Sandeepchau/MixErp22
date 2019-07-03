DROP FUNCTION IF EXISTS sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
);

CREATE FUNCTION sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
)
RETURNS bigint
AS
$$
    DECLARE _transaction_master_id              bigint;
    DECLARE _book_name                          national character varying(50) = 'Gift Card Fund Sales';
    DECLARE _payable_account_id                 integer;
    DECLARE _currency_code                      national character varying(12);
BEGIN
    _currency_code                              := core.get_currency_code_by_office_id(_office_id);
    _payable_account_id                         := sales.get_payable_account_id_by_gift_card_id(_gift_card_id);
    _transaction_master_id                      := nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, cost_center_id, reference_number, statement_reference)
    SELECT
        _transaction_master_id,
        finance.get_new_transaction_counter(_value_date),
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book_name,
        _value_date,
        _book_date,
        _login_id,
        _user_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Cr', 
        _payable_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Dr', 
        _debit_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO sales.gift_card_transactions(gift_card_id, value_date, book_date, transaction_master_id, transaction_type, amount)
    SELECT _gift_card_id, _value_date, _book_date, _transaction_master_id, 'Cr', _amount;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.add_gift_card_fund(1, 1, 1, sales.get_gift_card_id_by_gift_card_number('123456'), '1-1-2020', '1-1-2020', 1, 2000, 1, '', '');

