IF OBJECT_ID('hrm.employee_view') IS NOT NULL
DROP VIEW hrm.employee_view;

GO

CREATE VIEW hrm.employee_view
AS
SELECT
    hrm.employees.employee_id,
    hrm.employees.first_name,
    hrm.employees.middle_name,
    hrm.employees.last_name,
    hrm.employees.employee_code,
    hrm.employees.employee_name,
    hrm.employees.gender_code,
    core.genders.gender_name,
    core.marital_statuses.marital_status_code + ' (' + core.marital_statuses.marital_status_name + ')' AS marital_status,
    hrm.employees.joined_on,
    hrm.employees.office_id,
    core.offices.office_code + ' (' + core.offices.office_name + ')' AS office,
    hrm.employees.user_id,
    account.users.name,
    hrm.employees.employee_type_id,
    hrm.employee_types.employee_type_code + ' (' + hrm.employee_types.employee_type_name + ')' AS employee_type,
    hrm.employees.current_department_id,
    hrm.departments.department_code + ' (' + hrm.departments.department_name + ')' AS current_department,    
    hrm.employees.current_role_id,
    hrm.roles.role_code + ' (' + hrm.roles.role_name + ')' AS role,
    hrm.employees.current_employment_status_id,
    hrm.employment_statuses.employment_status_code + ' (' + employment_status_name + ')' AS employment_status,
    hrm.employees.current_job_title_id,
    hrm.job_titles.job_title_code + ' (' + hrm.job_titles.job_title_name + ')' AS job_title,
    hrm.employees.current_pay_grade_id,
    hrm.pay_grades.pay_grade_code + ' (' + hrm.pay_grades.pay_grade_name + ')' AS pay_grade,
    hrm.employees.current_shift_id,
    hrm.shifts.shift_code + ' (' + hrm.shifts.shift_name + ')' AS shift,
    hrm.employees.nationality_id,
    hrm.nationalities.nationality_code + ' (' + hrm.nationalities.nationality_name + ')' AS nationality,
    hrm.employees.date_of_birth,
    hrm.employees.photo,
    hrm.employees.zip_code,
    hrm.employees.address_line_1,
    hrm.employees.address_line_2,
    hrm.employees.street,
    hrm.employees.city,
    hrm.employees.state,
    hrm.employees.country_code,
    core.countries.country_name AS country,
    hrm.employees.phone_home,
    hrm.employees.phone_cell,
    hrm.employees.phone_office_extension,
    hrm.employees.phone_emergency,
    hrm.employees.phone_emergency_2,
    hrm.employees.email_address,
    hrm.employees.website,
    hrm.employees.blog,
    hrm.employees.is_smoker,
    hrm.employees.is_alcoholic,
    hrm.employees.with_disabilities,
    hrm.employees.low_vision,
    hrm.employees.uses_wheelchair,
    hrm.employees.hard_of_hearing,
    hrm.employees.is_aphonic,
    hrm.employees.is_cognitively_disabled,
    hrm.employees.is_autistic
FROM hrm.employees
LEFT JOIN core.genders
ON hrm.employees.gender_code = core.genders.gender_code
LEFT JOIN core.marital_statuses
ON hrm.employees.marital_status_id = core.marital_statuses.marital_status_id
LEFT JOIN core.offices
ON hrm.employees.office_id = core.offices.office_id
LEFT JOIN hrm.departments
ON hrm.employees.current_department_id = hrm.departments.department_id
LEFT JOIN hrm.employee_types
ON hrm.employee_types.employee_type_id = hrm.employees.employee_type_id
LEFT JOIN hrm.employment_statuses
ON hrm.employees.current_employment_status_id = hrm.employment_statuses.employment_status_id
LEFT JOIN hrm.job_titles
ON hrm.employees.current_job_title_id = hrm.job_titles.job_title_id
LEFT JOIN hrm.pay_grades
ON hrm.employees.current_pay_grade_id = hrm.pay_grades.pay_grade_id
LEFT JOIN hrm.shifts
ON hrm.employees.current_shift_id = hrm.shifts.shift_id
LEFT JOIN account.users
ON hrm.employees.user_id = account.users.user_id
LEFT JOIN hrm.roles
ON hrm.employees.current_role_id = hrm.roles.role_id
LEFT JOIN hrm.nationalities
ON hrm.employees.nationality_id = hrm.nationalities.nationality_id
LEFT JOIN core.countries
ON hrm.employees.country_code = core.countries.country_code
WHERE (service_ended_on IS NULL OR COALESCE(service_ended_on, CAST(CAST(-53690 AS datetime) AS date)) >= GETUTCDATE())
AND hrm.employees.deleted = 0;

GO
