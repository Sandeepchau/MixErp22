IF OBJECT_ID('hrm.employment_status_code_selector_view') IS NOT NULL
DROP VIEW hrm.employment_status_code_selector_view;

GO



CREATE VIEW hrm.employment_status_code_selector_view
AS
SELECT
    hrm.employment_status_codes.employment_status_code_id,
    hrm.employment_status_codes.status_code + ' (' + hrm.employment_status_codes.status_code_name + ')' AS employment_status_code_name
FROM hrm.employment_status_codes
WHERE hrm.employment_status_codes.deleted = 0;


GO
