﻿IF OBJECT_ID('hrm.termination_scrud_view') IS NOT NULL
DROP VIEW hrm.termination_scrud_view;

GO



CREATE VIEW hrm.termination_scrud_view
AS
SELECT
    hrm.terminations.termination_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    hrm.terminations.notice_date,
    hrm.terminations.service_end_date,
    forwarded_to.employee_code + ' (' + forwarded_to.employee_name + ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code + ' (' + hrm.employment_statuses.employment_status_name + ')' AS employment_status,
    hrm.terminations.reason,
    hrm.terminations.details
FROM hrm.terminations
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.terminations.employee_id
INNER JOIN hrm.employment_statuses
ON hrm.employment_statuses.employment_status_id = hrm.terminations.change_status_to
INNER JOIN hrm.employees AS forwarded_to
ON forwarded_to.employee_id = hrm.terminations.forward_to
WHERE hrm.terminations.deleted = 0;

GO
