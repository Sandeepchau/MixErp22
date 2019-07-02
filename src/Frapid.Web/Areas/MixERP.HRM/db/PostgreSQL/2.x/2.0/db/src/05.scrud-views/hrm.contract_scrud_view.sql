DROP VIEW IF EXISTS hrm.contract_scrud_view;

CREATE VIEW hrm.contract_scrud_view
AS
SELECT
    hrm.contracts.contract_id,
    hrm.employees.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    core.offices.office_code || ' (' || core.offices.office_name || ')' AS office,
    hrm.departments.department_code || ' (' || hrm.departments.department_name || ')' AS department,
    hrm.roles.role_code || ' (' || hrm.roles.role_name || ')' AS role,
    hrm.leave_benefits.leave_benefit_code || ' (' || hrm.leave_benefits.leave_benefit_name || ')' AS leave_benefit,
    hrm.employment_status_codes.status_code || ' (' || hrm.employment_status_codes.status_code_name || ')' AS employment_status_code,
    hrm.contracts.began_on,
    hrm.contracts.ended_on
FROM hrm.contracts
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.contracts.employee_id
INNER JOIN core.offices
ON core.offices.office_id = hrm.contracts.office_id
INNER JOIN hrm.departments
ON hrm.departments.department_id = hrm.contracts.department_id
INNER JOIN hrm.roles
ON hrm.roles.role_id = hrm.contracts.role_id
INNER JOIN hrm.employment_status_codes
ON hrm.employment_status_codes.employment_status_code_id = hrm.contracts.employment_status_code_id
LEFT JOIN hrm.leave_benefits
ON hrm.leave_benefits.leave_benefit_id = hrm.contracts.leave_benefit_id
WHERE NOT hrm.contracts.deleted;