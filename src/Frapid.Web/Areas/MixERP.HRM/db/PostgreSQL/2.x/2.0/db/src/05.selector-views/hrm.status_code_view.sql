DROP VIEW IF EXISTS hrm.status_code_view;

CREATE VIEW hrm.status_code_view
AS
SELECT
	hrm.employment_status_codes.employment_status_code_id AS status_code_id,
	hrm.employment_status_codes.status_code,
	hrm.employment_status_codes.status_code_name
FROM hrm.employment_status_codes
WHERE NOT hrm.employment_status_codes.deleted;
