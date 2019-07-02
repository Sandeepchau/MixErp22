DROP VIEW IF EXISTS hrm.employment_status_code_selector_view;

CREATE VIEW hrm.employment_status_code_selector_view
AS
SELECT
    hrm.employment_status_codes.employment_status_code_id,
    hrm.employment_status_codes.status_code || ' (' || hrm.employment_status_codes.status_code_name || ')' AS employment_status_code_name
FROM hrm.employment_status_codes
WHERE NOT hrm.employment_status_codes.deleted;
