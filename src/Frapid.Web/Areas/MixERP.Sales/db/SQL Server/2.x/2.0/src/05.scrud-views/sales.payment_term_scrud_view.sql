IF OBJECT_ID('sales.payment_term_scrud_view') IS NOT NULL
DROP VIEW sales.payment_term_scrud_view;

GO



CREATE VIEW sales.payment_term_scrud_view
AS
SELECT
    sales.payment_terms.payment_term_id,
    sales.payment_terms.payment_term_code,
    sales.payment_terms.payment_term_name,
    sales.payment_terms.due_on_date,
    sales.payment_terms.due_days,
    due_fequency.frequency_code + ' (' + due_fequency.frequency_name + ')' AS due_fequency,
    sales.payment_terms.grace_period,
    sales.late_fee.late_fee_code + ' (' + sales.late_fee.late_fee_name + ')' AS late_fee,
    late_fee_frequency.frequency_code + ' (' + late_fee_frequency.frequency_name + ')' AS late_fee_frequency
FROM sales.payment_terms
INNER JOIN finance.frequencies AS due_fequency
ON due_fequency.frequency_id = sales.payment_terms.due_frequency_id
INNER JOIN finance.frequencies AS late_fee_frequency
ON late_fee_frequency.frequency_id = sales.payment_terms.late_fee_posting_frequency_id
INNER JOIN sales.late_fee
ON sales.late_fee.late_fee_id = sales.payment_terms.late_fee_id
WHERE sales.payment_terms.deleted = 0;



GO
