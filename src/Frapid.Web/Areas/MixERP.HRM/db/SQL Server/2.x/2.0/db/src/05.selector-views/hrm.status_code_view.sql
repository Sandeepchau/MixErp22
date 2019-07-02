IF OBJECT_ID('hrm.status_code_view') IS NOT NULL
DROP VIEW hrm.status_code_view;

GO

CREATE VIEW hrm.status_code_view
AS
SELECT
	hrm.employment_status_codes.employment_status_code_id AS status_code_id,
	hrm.employment_status_codes.status_code,
	hrm.employment_status_codes.status_code_name
FROM hrm.employment_status_codes
WHERE hrm.employment_status_codes.deleted = 0;

GO
