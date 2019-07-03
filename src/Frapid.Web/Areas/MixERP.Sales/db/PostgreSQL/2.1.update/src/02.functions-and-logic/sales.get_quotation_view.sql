DROP FUNCTION IF EXISTS sales.get_quotation_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
);

CREATE FUNCTION sales.get_quotation_view
(
    _user_id                        integer,
    _office_id                      integer,
    _customer                       national character varying(500),
    _from                           date,
    _to                             date,
    _expected_from                  date,
    _expected_to                    date,
    _id                             bigint,
    _reference_number               national character varying(500),
    _internal_memo                  national character varying(500),
    _terms                          national character varying(500),
    _posted_by                      national character varying(500),
    _office                         national character varying(500)
)
RETURNS TABLE
(
    id                              bigint,
    customer                        national character varying(500),
    value_date                      date,
    expected_date                   date,
    reference_number                national character varying(24),
    terms                           national character varying(500),
    internal_memo                   national character varying(500),
    posted_by                       national character varying(500),
    office                          national character varying(500),
    transaction_ts                  TIMESTAMP WITH TIME ZONE
)
AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE office_cte(office_id) AS 
    (
        SELECT _office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    SELECT 
        sales.quotations.quotation_id,
        inventory.get_customer_name_by_customer_id(sales.quotations.customer_id),
        sales.quotations.value_date,
        sales.quotations.expected_delivery_date,
        sales.quotations.reference_number,
        sales.quotations.terms,
        sales.quotations.internal_memo,
        account.get_name_by_user_id(sales.quotations.user_id)::national character varying(500) AS posted_by,
        core.get_office_name_by_office_id(office_id)::national character varying(500) AS office,
        sales.quotations.transaction_timestamp
    FROM sales.quotations
    WHERE 1 = 1
    AND sales.quotations.value_date BETWEEN _from AND _to
    AND sales.quotations.expected_delivery_date BETWEEN _expected_from AND _expected_to
    AND sales.quotations.office_id IN (SELECT office_id FROM office_cte)
    AND (COALESCE(_id, 0) = 0 OR _id = sales.quotations.quotation_id)
    AND COALESCE(LOWER(sales.quotations.reference_number), '') LIKE '%' || LOWER(_reference_number) || '%' 
    AND COALESCE(LOWER(sales.quotations.internal_memo), '') LIKE '%' || LOWER(_internal_memo) || '%' 
    AND COALESCE(LOWER(sales.quotations.terms), '') LIKE '%' || LOWER(_terms) || '%' 
    AND LOWER(inventory.get_customer_name_by_customer_id(sales.quotations.customer_id)) LIKE '%' || LOWER(_customer) || '%' 
    AND LOWER(account.get_name_by_user_id(sales.quotations.user_id)) LIKE '%' || LOWER(_posted_by) || '%' 
    AND LOWER(core.get_office_name_by_office_id(sales.quotations.office_id)) LIKE '%' || LOWER(_office) || '%' 
    AND NOT sales.quotations.deleted;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.get_quotation_view(1,1,'','11/27/2010','11/27/2016','1-1-2000','1-1-2020', null,'','','','', '');
