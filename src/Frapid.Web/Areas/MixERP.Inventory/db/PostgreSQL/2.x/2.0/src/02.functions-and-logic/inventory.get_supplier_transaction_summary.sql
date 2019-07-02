DROP FUNCTION IF EXISTS inventory.get_supplier_transaction_summary
(
    office_id                   integer, 
    supplier_id                 integer
);

CREATE FUNCTION inventory.get_supplier_transaction_summary
(
    office_id                   integer, 
    supplier_id                 integer
)
RETURNS TABLE
(
    currency_code               national character varying(12), 
    currency_symbol             national character varying(12), 
    total_due_amount            numeric(30, 6), 
    office_due_amount           numeric(30, 6)
)
AS
$$
    DECLARE root_office_id      integer = 0;
    DECLARE _currency_code      national character varying(12); 
    DECLARE _currency_symbol    national character varying(12);
    DECLARE _total_due_amount   numeric(30, 6); 
    DECLARE _office_due_amount  numeric(30, 6); 
    DECLARE _last_receipt_date  date;
    DECLARE _transaction_value  numeric(30, 6);
BEGIN
    _currency_code := inventory.get_currency_code_by_supplier_id(supplier_id);

    SELECT core.currencies.currency_symbol 
    INTO _currency_symbol
    FROM core.currencies
    WHERE core.currencies.currency_code = _currency_code;

    SELECT core.offices.office_id INTO root_office_id
    FROM core.offices
    WHERE parent_office_id IS NULL;



    _total_due_amount := inventory.get_total_supplier_due(root_office_id, supplier_id);
    _office_due_amount := inventory.get_total_supplier_due(office_id, supplier_id);

    RETURN QUERY
    SELECT _currency_code, _currency_symbol, _total_due_amount, _office_due_amount;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_supplier_transaction_summary(1, 1);