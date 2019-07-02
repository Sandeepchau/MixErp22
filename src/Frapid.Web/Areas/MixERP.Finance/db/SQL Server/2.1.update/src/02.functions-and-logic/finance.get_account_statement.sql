IF OBJECT_ID('finance.get_account_statement') IS NOT NULL
DROP FUNCTION finance.get_account_statement;

GO

CREATE FUNCTION finance.get_account_statement
(
    @date_from        		date,
    @date_to          		date,
    @user_id                integer,
    @account_id             integer,
    @office_id              integer,
    @dont_include_children	bit = 0
)
RETURNS @result TABLE
(
    id                      integer IDENTITY,
	transaction_id	        bigint,
	transaction_detail_id	bigint,
    value_date              date,
    book_date               date,
    tran_code               national character varying(1000),
    reference_number        national character varying(1000),
    statement_reference     national character varying(1000),
    reconciliation_memo     national character varying(1000),
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    balance                 numeric(30, 6),
    office                  national character varying(1000),
    book                    national character varying(1000),
    account_id              integer,
    account_number          national character varying(1000),
    account                 national character varying(1000),
    posted_on               date,
    posted_by               national character varying(1000),
    approved_by             national character varying(1000),
    verification_status     integer
)
AS
BEGIN
    DECLARE @normally_debit bit = finance.is_normally_debit(@account_id);

	DECLARE @temp_account_ids TABLE
	(
		account_id				integer
	);

	IF(@dont_include_children = 0)
	BEGIN
		INSERT INTO @temp_account_ids
		SELECT * FROM finance.get_account_ids(@account_id);
	END
	ELSE
	BEGIN
		INSERT INTO @temp_account_ids
		SELECT @account_id;
	END


    INSERT INTO @result(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        @date_from,
        @date_from,
        NULL,
        NULL,
        'Opening Balance',
        NULL,
        SUM
        (
            CASE finance.transaction_details.tran_type
            WHEN 'Cr' THEN amount_in_local_currency
            ELSE amount_in_local_currency * -1 
            END            
        ) as credit,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.book_date < @date_from
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM @temp_account_ids)
    AND finance.transaction_master.deleted = 0;

    DELETE FROM @result
    WHERE COALESCE(debit, 0) = 0
    AND COALESCE(credit, 0) = 0;
    

    UPDATE @result 
	SET 
		debit = credit * -1,
		credit = 0
    WHERE credit < 0;
    

    INSERT INTO @result(transaction_id, transaction_detail_id, value_date, book_date, tran_code, reference_number, statement_reference, reconciliation_memo, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
		finance.transaction_details.transaction_master_id,
		finance.transaction_details.transaction_detail_id,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master. transaction_code,
        finance.transaction_master.reference_number,
        finance.transaction_details.statement_reference,
		finance.transaction_details.reconciliation_memo,
        CASE finance.transaction_details.tran_type
        WHEN 'Dr' THEN amount_in_local_currency
        ELSE NULL END,
        CASE finance.transaction_details.tran_type
        WHEN 'Cr' THEN amount_in_local_currency
        ELSE NULL END,
        core.get_office_name_by_office_id(finance.transaction_master.office_id),
        finance.transaction_master.book,
        finance.transaction_details.account_id,
        finance.transaction_master.transaction_ts,
        account.get_name_by_user_id(finance.transaction_master.user_id),
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id),
        finance.transaction_master.verification_status_id
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.book_date >= @date_from
    AND finance.transaction_master.book_date <= @date_to
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM @temp_account_ids)
    AND finance.transaction_master.deleted = 0
    ORDER BY 
        finance.transaction_master.value_date,
        finance.transaction_master.transaction_ts,
        finance.transaction_master.book_date,
        finance.transaction_master.last_verified_on;

	UPDATE result
    SET 
		balance = c.balance
	FROM @result AS result, 
    (
        SELECT
            result.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM @result AS result
        LEFT JOIN @result AS c 
            ON (c.id <= result.id)
        GROUP BY result.id
        --ORDER BY @result.id
    ) AS c
    WHERE result.id = c.id;
	


    UPDATE result 
	SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM @result AS result, finance.accounts
    WHERE result.account_id = finance.accounts.account_id;


    IF(@normally_debit = 1)
	BEGIN
        UPDATE @result SET balance = balance * -1;
    END;

    RETURN;
END;

GO
-- SELECT * FROM finance.get_account_statement
-- (
    -- '1-1-2000',
    -- '1-1-2050',
    -- 1,
    -- 1,
    -- 1,
    -- 0
-- )