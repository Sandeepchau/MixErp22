﻿IF OBJECT_ID('hrm.leave_application_verification_scrud_view') IS NOT NULL
DROP VIEW hrm.leave_application_verification_scrud_view;

GO



CREATE VIEW hrm.leave_application_verification_scrud_view
AS
SELECT
    hrm.leave_applications.leave_application_id,
    hrm.leave_applications.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    hrm.leave_types.leave_type_code + ' (' + hrm.leave_types.leave_type_name + ')' AS leave_type,
    account.users.name AS entered_by,
    hrm.leave_applications.applied_on,
    hrm.leave_applications.reason,
    hrm.leave_applications.start_date,
    hrm.leave_applications.end_date
FROM hrm.leave_applications
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.leave_applications.employee_id
INNER JOIN hrm.leave_types
ON hrm.leave_types.leave_type_id = hrm.leave_applications.leave_type_id
INNER JOIN account.users
ON account.users.user_id = hrm.leave_applications.entered_by
WHERE verification_status_id = 0
AND hrm.leave_applications.deleted = 0;

GO
