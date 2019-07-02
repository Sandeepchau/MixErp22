IF OBJECT_ID('hrm.employee_type_scrud_view') IS NOT NULL
DROP VIEW hrm.employee_type_scrud_view;

GO



CREATE VIEW hrm.employee_type_scrud_view
AS
SELECT
    employee_type_id,
    employee_type_code,
    employee_type_name
FROM hrm.employee_types
WHERE hrm.employee_types.deleted = 0;

GO
