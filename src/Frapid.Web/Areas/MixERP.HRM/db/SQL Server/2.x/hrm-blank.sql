-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
 /********************************************************************************
Copyright (C) MixERP Inc. (http://mixof.org).
This file is part of MixERP.
MixERP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 2 of the License.
MixERP is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with MixERP.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************************/

EXECUTE dbo.drop_schema 'hrm';
GO
CREATE SCHEMA hrm;
GO


CREATE TABLE hrm.week_days
(
    week_day_id                             integer NOT NULL CHECK(week_day_id> = 1 AND week_day_id<=7) PRIMARY KEY,
    week_day_code                           national character varying(12) NOT NULL UNIQUE,
    week_day_name                           national character varying(50) NOT NULL UNIQUE,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)
);

CREATE UNIQUE INDEX week_days_week_day_code_uix
ON hrm.week_days(week_day_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX week_days_week_day_name_uix
ON hrm.week_days(week_day_name)
WHERE deleted = 0;

CREATE TABLE hrm.identification_types
(
	identification_type_id					integer IDENTITY PRIMARY KEY,
    identification_type_code                national character varying(12) NOT NULL,
    identification_type_name                national character varying(100) NOT NULL UNIQUE,
    can_expire                           	bit NOT NULL DEFAULT(0),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)    
);

CREATE UNIQUE INDEX identification_types_identification_type_code_uix
ON hrm.identification_types(identification_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX identification_types_identification_type_name_uix
ON hrm.identification_types(identification_type_name)
WHERE deleted = 0;

CREATE TABLE hrm.social_networks
(
	social_network_id						integer IDENTITY PRIMARY KEY,
    social_network_name                     national character varying(128) NOT NULL,
    icon_css_class                          national character varying(128),
    base_url                                national character varying(128) DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)    
);

CREATE TABLE hrm.departments
(
    department_id                           integer IDENTITY PRIMARY KEY,
    department_code                         national character varying(12) NOT NULL,
    department_name                         national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX departments_department_code_uix
ON hrm.departments(department_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX departments_department_name_uix
ON hrm.departments(department_name)
WHERE deleted = 0;

CREATE TABLE hrm.roles
(
    role_id                                   integer IDENTITY PRIMARY KEY,
    role_code                                 national character varying(12) NOT NULL,
    role_name                                 national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX roles_role_code_uix
ON hrm.roles(role_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX roles_role_name_uix
ON hrm.roles(role_name)
WHERE deleted = 0;

CREATE TABLE hrm.nationalities
(
	nationality_id							integer IDENTITY PRIMARY KEY,
    nationality_code                        national character varying(12),
    nationality_name                        national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX nationalities_nationality_code_uix
ON hrm.nationalities(nationality_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX nationalities_nationality_name_uix
ON hrm.nationalities(nationality_name)
WHERE deleted = 0;

CREATE TABLE hrm.education_levels
(
    education_level_id                      integer IDENTITY NOT NULL PRIMARY KEY,
    education_level_name                    national character varying(50) NOT NULL UNIQUE,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX education_levels_education_level_name
ON hrm.education_levels(education_level_name)
WHERE deleted = 0;

CREATE TABLE hrm.employment_status_codes
(
    employment_status_code_id               integer NOT NULL PRIMARY KEY,
    status_code                             national character varying(12) NOT NULL UNIQUE,
    status_code_name                        national character varying(100) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX employment_status_codes_status_code_uix
ON hrm.employment_status_codes(status_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX employment_status_codes_status_code_name_uix
ON hrm.employment_status_codes(status_code_name)
WHERE deleted = 0;

CREATE TABLE hrm.employment_statuses
(
    employment_status_id                    integer IDENTITY NOT NULL PRIMARY KEY,
    employment_status_code                  national character varying(12) NOT NULL UNIQUE,
    employment_status_name                  national character varying(100) NOT NULL,
    is_contract                          bit NOT NULL DEFAULT(0),
    default_employment_status_code_id       integer NOT NULL REFERENCES hrm.employment_status_codes,
    description                             national character varying(1000) DEFAULT(''),    
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX employment_statuses_employment_status_code_uix
ON hrm.employment_statuses(employment_status_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX employment_statuses_employment_status_name_uix
ON hrm.employment_statuses(employment_status_name)
WHERE deleted = 0;

CREATE TABLE hrm.job_titles
(
    job_title_id                            integer IDENTITY NOT NULL PRIMARY KEY,
    job_title_code                          national character varying(12) NOT NULL UNIQUE,
    job_title_name                          national character varying(100) NOT NULL,
    description                             national character varying(1000) DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX job_titles_job_title_code_uix
ON hrm.job_titles(job_title_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX job_titles_job_title_name_uix
ON hrm.job_titles(job_title_name)
WHERE deleted = 0;

CREATE TABLE hrm.pay_grades
(
    pay_grade_id                            integer IDENTITY NOT NULL PRIMARY KEY,
    pay_grade_code                          national character varying(12) NOT NULL UNIQUE,
    pay_grade_name                          national character varying(100) NOT NULL,
    minimum_salary                          numeric(30, 6) NOT NULL,
    maximum_salary                          numeric(30, 6) NOT NULL,
                                            CHECK(maximum_salary >= minimum_salary),
    description                             national character varying(1000) DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX pay_grades_pay_grade_code_uix
ON hrm.pay_grades(pay_grade_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX pay_grades_pay_grade_name_uix
ON hrm.pay_grades(pay_grade_name)
WHERE deleted = 0;

CREATE TABLE hrm.shifts
(
    shift_id                                integer IDENTITY NOT NULL PRIMARY KEY,
    shift_code                              national character varying(12) NOT NULL UNIQUE,
    shift_name                              national character varying(100) NOT NULL,
    begins_from                             time NOT NULL,
    ends_on                                 time NOT NULL,
    description                             national character varying(1000) DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX shifts_shift_code_uix
ON hrm.shifts(shift_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX shifts_shift_name_uix
ON hrm.shifts(shift_name)
WHERE deleted = 0;

CREATE TABLE hrm.leave_types
(
    leave_type_id                           integer IDENTITY NOT NULL PRIMARY KEY,
    leave_type_code                         national character varying(12) NOT NULL UNIQUE,
    leave_type_name                         national character varying(100) NOT NULL,
    description                             national character varying(1000) DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX leave_types_leave_type_code_uix
ON hrm.leave_types(leave_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX leave_types_leave_type_name_uix
ON hrm.leave_types(leave_type_name)
WHERE deleted = 0;

CREATE TABLE hrm.office_hours
(
    office_hour_id                          integer IDENTITY NOT NULL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    shift_id                                integer NOT NULL REFERENCES hrm.shifts,
    week_day_id                             integer NOT NULL REFERENCES hrm.week_days,
    begins_from                             time NOT NULL,
    ends_on                                 time NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)    
);

CREATE TABLE hrm.leave_benefits
(
    leave_benefit_id                        integer IDENTITY NOT NULL PRIMARY KEY,
    leave_benefit_code                      national character varying(12) NOT NULL UNIQUE,
    leave_benefit_name                      national character varying(128) NOT NULL,
    total_days                              integer NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX leave_benefits_leave_benefit_code_uix
ON hrm.leave_benefits(leave_benefit_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX leave_benefits_leave_benefit_name_uix
ON hrm.leave_benefits(leave_benefit_name)
WHERE deleted = 0;

CREATE TABLE hrm.employee_types
(
    employee_type_id                        integer IDENTITY NOT NULL PRIMARY KEY,
    employee_type_code                      national character varying(12) NOT NULL UNIQUE,
    employee_type_name                      national character varying(128) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX employee_types_employee_type_code_uix
ON hrm.employee_types(employee_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX employee_types_employee_type_name_uix
ON hrm.employee_types(employee_type_name)
WHERE deleted = 0;

CREATE TABLE hrm.employees
(
    employee_id                             integer IDENTITY NOT NULL PRIMARY KEY,
    employee_code                           national character varying(12) NOT NULL UNIQUE,
    first_name                              national character varying(50) NOT NULL,
    middle_name                             national character varying(50) DEFAULT(''),
    last_name                               national character varying(50) DEFAULT(''),
    employee_name                           national character varying(160) NOT NULL,
    gender_code                             national character varying(4) NOT NULL 
                                            REFERENCES core.genders,
    marital_status_id                       integer NOT NULL REFERENCES core.marital_statuses,
    joined_on                               date NULL,
    office_id                               integer NOT NULL REFERENCES core.offices,
    user_id                                 integer REFERENCES account.users,
    employee_type_id                        integer NOT NULL REFERENCES hrm.employee_types,
    current_department_id                   integer NOT NULL REFERENCES hrm.departments,
    current_role_id                         integer REFERENCES hrm.roles,
    current_employment_status_id            integer NOT NULL REFERENCES hrm.employment_statuses,
    current_job_title_id                    integer NOT NULL REFERENCES hrm.job_titles,
    current_pay_grade_id                    integer NOT NULL REFERENCES hrm.pay_grades,
    current_shift_id                        integer NOT NULL REFERENCES hrm.shifts,
    nationality_id                        	integer REFERENCES hrm.nationalities,
    date_of_birth                           date,
    photo                                   dbo.photo,
    bank_account_number                     national character varying(128) DEFAULT(''),
    bank_name                               national character varying(128) DEFAULT(''),
    bank_branch_name                        national character varying(128) DEFAULT(''),
    bank_reference_number                   national character varying(128) DEFAULT(''),
    zip_code                                national character varying(128) DEFAULT(''),
    address_line_1                          national character varying(128) DEFAULT(''),
    address_line_2                          national character varying(128) DEFAULT(''),
    street                                  national character varying(128) DEFAULT(''),
    city                                    national character varying(128) DEFAULT(''),
    state                                   national character varying(128) DEFAULT(''),    
    country_code                            national character varying(12) REFERENCES core.countries,
    phone_home                              national character varying(128) DEFAULT(''),
    phone_cell                              national character varying(128) DEFAULT(''),
    phone_office_extension                  national character varying(128) DEFAULT(''),
    phone_emergency                         national character varying(128) DEFAULT(''),
    phone_emergency_2                       national character varying(128) DEFAULT(''),
    email_address                           national character varying(128) DEFAULT(''),
    website                                 national character varying(128) DEFAULT(''),
    blog                                    national character varying(128) DEFAULT(''),
    is_smoker                           	bit,
    is_alcoholic                         	bit,
    with_disabilities                    	bit,
    low_vision                           	bit,
    uses_wheelchair                      	bit,
    hard_of_hearing                      	bit,
    is_aphonic                           	bit,
    is_cognitively_disabled              	bit,
    is_autistic                          	bit,
    service_ended_on                        date NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX employees_employee_code_uix
ON hrm.employees(employee_code)
WHERE deleted = 0;

CREATE TABLE hrm.employee_identification_details
(
    employee_identification_detail_id       bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    identification_type_id                	integer NOT NULL REFERENCES hrm.identification_types,
    identification_number                   national character varying(128) NOT NULL,
    expires_on                              date,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)                                  
);

CREATE UNIQUE INDEX employee_identification_details_employee_id_itc_uix
ON hrm.employee_identification_details(employee_id, identification_type_id)
WHERE deleted = 0;

CREATE TABLE hrm.employee_social_network_details
(
    employee_social_network_detail_id       bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    social_network_id                     	integer NOT NULL REFERENCES hrm.social_networks,
    profile_link                       		national character varying(1000) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)
);

CREATE TABLE hrm.contracts
(
    contract_id                             bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    office_id                               integer NOT NULL REFERENCES core.offices,
    department_id                           integer NOT NULL REFERENCES hrm.departments,
    role_id                                 integer REFERENCES hrm.roles,
    leave_benefit_id                        integer REFERENCES hrm.leave_benefits,
    began_on                                date,
    ended_on                                date,
    employment_status_code_id               integer NOT NULL REFERENCES hrm.employment_status_codes,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE hrm.employee_experiences
(
    employee_experience_id                  bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    organization_name                       national character varying(128) NOT NULL,
    title                                   national character varying(128) NOT NULL,
    started_on                              date,
    ended_on                                date,
    details                                 national character varying(1000),
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE hrm.employee_qualifications
(
    employee_qualification_id               bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    education_level_id                      integer NOT NULL REFERENCES hrm.education_levels,
    institution                             national character varying(128) NOT NULL,
    majors                                  national character varying(128) NOT NULL,
    total_years                             integer,
    score                                   numeric(30, 6),
    started_on                              date,
    completed_on                            date,
    details                                 national character varying(1000),
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE hrm.leave_applications
(
    leave_application_id                    bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    leave_type_id                           integer NOT NULL REFERENCES hrm.leave_types,
    entered_by                              integer NOT NULL REFERENCES account.users,
    applied_on                              date DEFAULT(GETUTCDATE()),
    reason                                  national character varying(1000),
    start_date                              date,
    end_date                                date,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE hrm.resignations
(
    resignation_id                          integer IDENTITY NOT NULL PRIMARY KEY,
    entered_by                              integer NOT NULL REFERENCES account.users,
    notice_date                             date NOT NULL,
    desired_resign_date                     date NOT NULL,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    forward_to                              integer REFERENCES hrm.employees,
    reason                                  national character varying(128) NOT NULL,
    details                                 national character varying(1000),
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE hrm.terminations
(
    termination_id                          integer IDENTITY NOT NULL PRIMARY KEY,
    notice_date                             date NOT NULL,
    employee_id                             integer NOT NULL REFERENCES hrm.employees UNIQUE,
    forward_to                              integer REFERENCES hrm.employees,
    change_status_to                        integer NOT NULL REFERENCES hrm.employment_statuses,
    reason                                  national character varying(128) NOT NULL,
    details                                 national character varying(1000),
    service_end_date                        date NOT NULL,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
    
);

CREATE TABLE hrm.exit_types
(
    exit_type_id                            integer IDENTITY NOT NULL PRIMARY KEY,
    exit_type_code                          national character varying(12) NOT NULL UNIQUE,
    exit_type_name                          national character varying(128) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX exit_types_exit_type_code_uix
ON hrm.exit_types(exit_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX exit_types_exit_type_name_uix
ON hrm.exit_types(exit_type_name)
WHERE deleted = 0;

CREATE TABLE hrm.exits
(
    exit_id                                 bigint IDENTITY NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    forward_to                              integer REFERENCES hrm.employees,
    change_status_to                        integer NOT NULL REFERENCES hrm.employment_statuses,
    exit_type_id                            integer NOT NULL REFERENCES hrm.exit_types,
    exit_interview_details                  national character varying(1000),
    reason                                  national character varying(128) NOT NULL,
    details                                 national character varying(1000),
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    service_end_date                        date NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);


CREATE TABLE hrm.attendances
(
    attendance_id                           bigint IDENTITY NOT NULL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    attendance_date                         date NOT NULL,
    was_present                          	bit NOT NULL,
    check_in_time                           time NULL,
    check_out_time                          time NULL,
    overtime_hours                          numeric(30, 6) NOT NULL,
    was_absent                           	bit NOT NULL,
                                            CHECK(was_absent != was_present),
    reason_for_absenteeism                  national character varying(1000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                              	bit DEFAULT(0)
);

CREATE UNIQUE INDEX attendance_date_employee_id_uix
ON hrm.attendances(attendance_date, employee_id)
WHERE deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_by_employee_id.sql --<--<--
IF OBJECT_ID('hrm.get_employee_by_employee_id') IS NOT NULL
DROP FUNCTION hrm.get_employee_by_employee_id;

GO

CREATE FUNCTION hrm.get_employee_by_employee_id(@employee_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT
	        employee_code + ' (' + employee_name + ')'      
	    FROM hrm.employees
	    WHERE hrm.employees.employee_id = @employee_id
	    AND hrm.employees.deleted = 0
	);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_code_by_employee_id.sql --<--<--
IF OBJECT_ID('hrm.get_employee_code_by_employee_id') IS NOT NULL
DROP FUNCTION hrm.get_employee_code_by_employee_id;

GO

CREATE FUNCTION hrm.get_employee_code_by_employee_id(@employee_id integer)
RETURNS national character varying(24)
AS
BEGIN
    RETURN
    (
	    SELECT
	        employee_code
	    FROM hrm.employees
	    WHERE hrm.employees.employee_id = @employee_id
	    AND hrm.employees.deleted = 0
	);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_name_by_employee_id.sql --<--<--
IF OBJECT_ID('hrm.get_employee_name_by_employee_id') IS NOT NULL
DROP FUNCTION hrm.get_employee_name_by_employee_id;

GO

CREATE FUNCTION hrm.get_employee_name_by_employee_id(@employee_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT
	        employee_name
	    FROM hrm.employees
	    WHERE hrm.employees.employee_id = @employee_id
	    AND hrm.employees.deleted = 0
	);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/03.menus/menus.sql --<--<--
DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.HRM'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.HRM'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.HRM';


EXECUTE core.create_app 'MixERP.HRM', 'HRM', 'HRM', '1.0', 'MixERP Inc.', 'December 1, 2015', 'user yellow', '/dashboard/hrm/tasks/employees', NULL;

EXECUTE core.create_menu 'MixERP.HRM', 'Tasks', 'Tasks', '', 'tasks icon', '';
EXECUTE core.create_menu 'MixERP.HRM', 'Attendance', 'Attendance', '/dashboard/hrm/tasks/attendance', 'check square', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'Employees', 'Employees', '/dashboard/hrm/tasks/employees', 'users', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'Contracts', 'Contracts', '/dashboard/hrm/tasks/contracts', 'write', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'LeaveApplications', 'Leave Applications', '/dashboard/hrm/tasks/leave-applications', 'share square', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'Resignations', 'Resignations', '/dashboard/hrm/tasks/resignations', 'remove user', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'Terminations', 'Terminations', '/dashboard/hrm/tasks/terminations', 'remove circle', 'Tasks';
EXECUTE core.create_menu 'MixERP.HRM', 'Exits', 'Exits', '/dashboard/hrm/tasks/exits', 'remove circle outline', 'Tasks';

EXECUTE core.create_menu 'MixERP.HRM', 'Verification', 'Verification', '', 'check circle', '';
EXECUTE core.create_menu 'MixERP.HRM', 'VerifyContracts', 'Verify Contracts', '/dashboard/hrm/verification/contracts', 'write square', 'Verification';
EXECUTE core.create_menu 'MixERP.HRM', 'VerifyLeaveApplications', 'Verify Leave Applications', '/dashboard/hrm/verification/leave-applications', 'checked calendar', 'Verification';
EXECUTE core.create_menu 'MixERP.HRM', 'VerifyResignations', 'Verify Resignations', '/dashboard/hrm/verification/resignations', 'mail forward', 'Verification';
EXECUTE core.create_menu 'MixERP.HRM', 'VerifyTerminations', 'Verify Terminations', '/dashboard/hrm/verification/terminations', 'erase', 'Verification';
EXECUTE core.create_menu 'MixERP.HRM', 'VerifyExits', 'Verify Exits', '/dashboard/hrm/verification/exits', 'send', 'Verification';

EXECUTE core.create_menu 'MixERP.HRM', 'SetupAndConfiguration', 'Setup & Configuration', '', 'configure', '';
EXECUTE core.create_menu 'MixERP.HRM', 'EmploymentStatuses', 'Employment Statuses', '/dashboard/hrm/setup/employment-statuses', 'info', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'EmployeeTypes', 'Employee Types', '/dashboard/hrm/setup/employee-types', 'child', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'IdentificationTypes', 'Identification Types', '/dashboard/hrm/setup/identification-types', 'child', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'EducationLevels', 'Education Levels', '/dashboard/hrm/setup/education-levels', 'student', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'JobTitles', 'Job Titles', '/dashboard/hrm/setup/job-titles', 'suitcase', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'PayGrades', 'Pay Grades', '/dashboard/hrm/setup/pay-grades', 'payment', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'Shifts', 'Shifts', '/dashboard/hrm/setup/shifts', 'paw', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'OfficeHours', 'Office Hours', '/dashboard/hrm/setup/office-hours', 'alarm outline', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'LeaveTypes', 'Leave Types', '/dashboard/hrm/setup/leave-types', 'hotel', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'LeaveBenefits', 'Leave Benefits', '/dashboard/hrm/setup/leave-benefits', 'car', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'ExitTypes', 'Exit Types', '/dashboard/hrm/setup/exit-types', 'remove', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'SocialNetworks', 'Social Networks', '/dashboard/hrm/setup/social-networks', 'users', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'Nationalities', 'Nationalities', '/dashboard/hrm/setup/nationalities', 'flag', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'MaritalStatuses', 'Marital Statuses', '/dashboard/hrm/setup/marital-statuses', 'smile', 'Setup & Configuration';

EXECUTE core.create_menu 'MixERP.HRM', 'Reports', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'MixERP.HRM', 'Attendances', 'Attendances', '/dashboard/hrm/reports/attendances', 'bullseye', 'Reports';




DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'MixERP.HRM',
'{*}';

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/04.default-values/01.default-values.sql --<--<--
INSERT INTO hrm.identification_types(identification_type_code, identification_type_name, can_expire)
SELECT 'SSN', 'Social Security Number', 0 UNION ALL
SELECT 'DLN', 'Driving License Number', 1;




-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.contract_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.contract_scrud_view') IS NOT NULL
DROP VIEW hrm.contract_scrud_view;

GO



CREATE VIEW hrm.contract_scrud_view
AS
SELECT
    hrm.contracts.contract_id,
    hrm.employees.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    core.offices.office_code + ' (' + core.offices.office_name + ')' AS office,
    hrm.departments.department_code + ' (' + hrm.departments.department_name + ')' AS department,
    hrm.roles.role_code + ' (' + hrm.roles.role_name + ')' AS role,
    hrm.leave_benefits.leave_benefit_code + ' (' + hrm.leave_benefits.leave_benefit_name + ')' AS leave_benefit,
    hrm.employment_status_codes.status_code + ' (' + hrm.employment_status_codes.status_code_name + ')' AS employment_status_code,
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
WHERE hrm.contracts.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.contract_verification_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.contract_verification_scrud_view') IS NOT NULL
DROP VIEW hrm.contract_verification_scrud_view;

GO



CREATE VIEW hrm.contract_verification_scrud_view
AS
SELECT
    hrm.contracts.contract_id,
    hrm.employees.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    core.offices.office_code + ' (' + core.offices.office_name + ')' AS office,
    hrm.departments.department_code + ' (' + hrm.departments.department_name + ')' AS department,
    hrm.roles.role_code + ' (' + hrm.roles.role_name + ')' AS role,
    hrm.leave_benefits.leave_benefit_code + ' (' + hrm.leave_benefits.leave_benefit_name + ')' AS leave_benefit,
    hrm.employment_status_codes.status_code + ' (' + hrm.employment_status_codes.status_code_name + ')' AS employment_status_code,
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
WHERE verification_status_id = 0
AND hrm.contracts.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employee_experience_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.employee_experience_scrud_view') IS NOT NULL
DROP VIEW hrm.employee_experience_scrud_view;

GO



CREATE VIEW hrm.employee_experience_scrud_view
AS
SELECT
    hrm.employee_experiences.employee_experience_id,
    hrm.employee_experiences.employee_id,
    hrm.employees.employee_name,
    hrm.employee_experiences.organization_name,
    hrm.employee_experiences.title,
    hrm.employee_experiences.started_on,
    hrm.employee_experiences.ended_on
FROM hrm.employee_experiences
INNER JOIN hrm.employees
ON hrm.employee_experiences.employee_id = hrm.employees.employee_id
WHERE hrm.employee_experiences.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employee_identification_detail_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.employee_identification_detail_scrud_view') IS NOT NULL
DROP VIEW hrm.employee_identification_detail_scrud_view;

GO

CREATE VIEW hrm.employee_identification_detail_scrud_view
AS
SELECT
    hrm.employee_identification_details.employee_identification_detail_id,
    hrm.employee_identification_details.employee_id,
    hrm.employees.employee_name,
    hrm.employee_identification_details.identification_type_id,
    hrm.identification_types.identification_type_code,
    hrm.identification_types.identification_type_name,
    hrm.employee_identification_details.identification_number,
    hrm.employee_identification_details.expires_on
FROM hrm.employee_identification_details
INNER JOIN hrm.employees
ON hrm.employee_identification_details.employee_id = hrm.employees.employee_id
INNER JOIN hrm.identification_types
ON hrm.employee_identification_details.identification_type_id = hrm.identification_types.identification_type_id
WHERE hrm.employee_identification_details.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employee_qualification_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.employee_qualification_scrud_view') IS NOT NULL
DROP VIEW hrm.employee_qualification_scrud_view;

GO



CREATE VIEW hrm.employee_qualification_scrud_view
AS
SELECT
    hrm.employee_qualifications.employee_qualification_id,
    hrm.employee_qualifications.employee_id,
    hrm.employees.employee_name,
    hrm.education_levels.education_level_name,
    hrm.employee_qualifications.institution,
    hrm.employee_qualifications.majors,
    hrm.employee_qualifications.total_years,
    hrm.employee_qualifications.score,
    hrm.employee_qualifications.started_on,
    hrm.employee_qualifications.completed_on
FROM hrm.employee_qualifications
INNER JOIN hrm.employees
ON hrm.employee_qualifications.employee_id = hrm.employees.employee_id
INNER JOIN hrm.education_levels
ON hrm.employee_qualifications.education_level_id = hrm.education_levels.education_level_id
WHERE hrm.employee_qualifications.deleted = 0;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employee_social_network_detail_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.employee_social_network_detail_scrud_view') IS NOT NULL
DROP VIEW hrm.employee_social_network_detail_scrud_view;

GO

CREATE VIEW hrm.employee_social_network_detail_scrud_view
AS
SELECT
    hrm.employee_social_network_details.employee_social_network_detail_id,
    hrm.employee_social_network_details.employee_id,
    hrm.employees.employee_name,
    hrm.employee_social_network_details.social_network_id,
    hrm.social_networks.social_network_name,
    hrm.social_networks.icon_css_class,
    hrm.social_networks.base_url,
    hrm.employee_social_network_details.profile_link
FROM hrm.employee_social_network_details
INNER JOIN hrm.employees
ON hrm.employee_social_network_details.employee_id = hrm.employees.employee_id
INNER JOIN hrm.social_networks
ON hrm.social_networks.social_network_id = hrm.employee_social_network_details.social_network_id
WHERE hrm.employee_social_network_details.deleted = 0;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employee_type_scrud_view.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.employment_status_code_selector_view.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.exit_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.exit_scrud_view') IS NOT NULL
DROP VIEW hrm.exit_scrud_view;

GO



CREATE VIEW hrm.exit_scrud_view
AS
SELECT
    hrm.exits.exit_id,
    hrm.exits.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    hrm.exits.reason,
    forwarded_to.employee_code + ' (' + forwarded_to.employee_name + ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code + ' (' + hrm.employment_statuses.employment_status_name + ')' AS employment_status,
    hrm.exit_types.exit_type_code + ' (' + hrm.exit_types.exit_type_name + ')' AS exit_type,
    hrm.exits.details,
    hrm.exits.exit_interview_details
FROM hrm.exits
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.exits.employee_id
INNER JOIN hrm.employment_statuses
ON hrm.employment_statuses.employment_status_id = hrm.exits.change_status_to
INNER JOIN hrm.exit_types
ON hrm.exit_types.exit_type_id = hrm.exits.exit_type_id
INNER JOIN hrm.employees AS forwarded_to
ON forwarded_to.employee_id = hrm.exits.forward_to
WHERE hrm.exits.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.exit_verification_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.exit_verification_scrud_view') IS NOT NULL
DROP VIEW hrm.exit_verification_scrud_view;

GO

CREATE VIEW hrm.exit_verification_scrud_view
AS
SELECT
    hrm.exits.exit_id,
    hrm.exits.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    hrm.exits.reason,
    forwarded_to.employee_code + ' (' + forwarded_to.employee_name + ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code + ' (' + hrm.employment_statuses.employment_status_name + ')' AS employment_status,
    hrm.exit_types.exit_type_code + ' (' + hrm.exit_types.exit_type_name + ')' AS exit_type,
    hrm.exits.details,
    hrm.exits.exit_interview_details
FROM hrm.exits
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.exits.employee_id
INNER JOIN hrm.employment_statuses
ON hrm.employment_statuses.employment_status_id = hrm.exits.change_status_to
INNER JOIN hrm.exit_types
ON hrm.exit_types.exit_type_id = hrm.exits.exit_type_id
INNER JOIN hrm.employees AS forwarded_to
ON forwarded_to.employee_id = hrm.exits.forward_to
WHERE verification_status_id = 0
AND hrm.exits.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.leave_application_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.leave_application_scrud_view') IS NOT NULL
DROP VIEW hrm.leave_application_scrud_view;

GO



CREATE VIEW hrm.leave_application_scrud_view
AS
SELECT
    hrm.leave_applications.leave_application_id,
    hrm.leave_applications.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
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
WHERE hrm.leave_applications.deleted = 0;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.leave_application_verification_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.leave_application_verification_scrud_view') IS NOT NULL
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.office_hour_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.office_hour_scrud_view') IS NOT NULL
DROP VIEW hrm.office_hour_scrud_view;

GO



CREATE VIEW hrm.office_hour_scrud_view
AS
SELECT
    hrm.office_hours.office_hour_id,
    core.offices.office_code + ' (' + core.offices.office_name + ')' AS office,
    core.offices.logo as photo,
    hrm.shifts.shift_code + ' (' + hrm.shifts.shift_name + ')' AS shift,
    hrm.week_days.week_day_code + ' (' + hrm.week_days.week_day_name + ')' AS week_day,
    hrm.office_hours.begins_from,
    hrm.office_hours.ends_on
FROM hrm.office_hours
LEFT JOIN core.offices
ON core.offices.office_id = hrm.office_hours.office_id
LEFT JOIN hrm.shifts
ON hrm.shifts.shift_id = hrm.office_hours.shift_id
LEFT JOIN hrm.week_days
ON hrm.week_days.week_day_id = hrm.office_hours.week_day_id
WHERE hrm.office_hours.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.resignation_verification_view.sql --<--<--
IF OBJECT_ID('hrm.resignation_verification_scrud_view') IS NOT NULL
DROP VIEW hrm.resignation_verification_scrud_view;

GO



CREATE VIEW hrm.resignation_verification_scrud_view
AS
SELECT
    hrm.resignations.resignation_id,
    account.users.name AS entered_by,
    hrm.resignations.notice_date,
    hrm.resignations.desired_resign_date,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    forward_to.employee_code + ' (' + forward_to.employee_name + ')' AS forward_to,
    hrm.resignations.reason
FROM hrm.resignations
INNER JOIN account.users
ON account.users.user_id = hrm.resignations.entered_by
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.resignations.employee_id
INNER JOIN hrm.employees AS forward_to
ON forward_to.employee_id = hrm.resignations.forward_to
WHERE verification_status_id = 0
AND hrm.resignations.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.resignation_view.sql --<--<--
IF OBJECT_ID('hrm.resignation_scrud_view') IS NOT NULL
DROP VIEW hrm.resignation_scrud_view;

GO



CREATE VIEW hrm.resignation_scrud_view
AS
SELECT
    hrm.resignations.resignation_id,
    account.users.name AS entered_by,
    hrm.resignations.notice_date,
    hrm.resignations.desired_resign_date,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    forward_to.employee_code + ' (' + forward_to.employee_name + ')' AS forward_to,
    hrm.resignations.reason
FROM hrm.resignations
INNER JOIN account.users
ON account.users.user_id = hrm.resignations.entered_by
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.resignations.employee_id
INNER JOIN hrm.employees AS forward_to
ON forward_to.employee_id = hrm.resignations.forward_to
WHERE hrm.resignations.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.termination_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.termination_scrud_view') IS NOT NULL
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.scrud-views/hrm.termination_verification_scrud_view.sql --<--<--
IF OBJECT_ID('hrm.termination_verification_scrud_view') IS NOT NULL
DROP VIEW hrm.termination_verification_scrud_view;

GO



CREATE VIEW hrm.termination_verification_scrud_view
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
WHERE verification_status_id = 0
AND hrm.terminations.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.selector-views/hrm.status_code_view.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.views/hrm.attendance_view.sql --<--<--
IF OBJECT_ID('hrm.attendance_view') IS NOT NULL
DROP VIEW hrm.attendance_view;

GO



CREATE VIEW hrm.attendance_view
AS
SELECT
    hrm.attendances.attendance_id,
    hrm.attendances.office_id,
    core.offices.office_code + ' (' + core.offices.office_name + ')' AS office,
    hrm.attendances.employee_id,
    hrm.employees.employee_code + ' (' + hrm.employees.employee_name + ')' AS employee,
    hrm.employees.photo,
    hrm.attendances.attendance_date,
    hrm.attendances.was_present,
    hrm.attendances.check_in_time,
    hrm.attendances.check_out_time,
    hrm.attendances.overtime_hours,
    hrm.attendances.was_absent,
    hrm.attendances.reason_for_absenteeism
FROM hrm.attendances
INNER JOIN core.offices
ON core.offices.office_id = hrm.attendances.office_id
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.attendances.employee_id
AND hrm.attendances.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/05.views/hrm.employee_view.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/99.ownership.sql --<--<--
IF(IS_ROLEMEMBER ('db_owner') = 1)
BEGIN
	EXEC sp_addrolemember  @rolename = 'db_owner', @membername  = 'frapid_db_user';
END
GO

IF(IS_ROLEMEMBER ('db_owner') = 1)
BEGIN
	EXEC sp_addrolemember  @rolename = 'db_datareader', @membername  = 'report_user'
END
GO

DECLARE @proc sysname
DECLARE @cmd varchar(8000)

DECLARE cur CURSOR FOR 
SELECT '[' + schema_name(schema_id) + '].[' + name + ']' FROM sys.objects
WHERE type IN('FN')
AND is_ms_shipped = 0
ORDER BY 1
OPEN cur
FETCH next from cur into @proc
WHILE @@FETCH_STATUS = 0
BEGIN
     SET @cmd = 'GRANT EXEC ON ' + @proc + ' TO report_user';
     EXEC (@cmd)

     FETCH next from cur into @proc
END
CLOSE cur
DEALLOCATE cur

GO


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.x/2.0/db/src/99.sample/kanban.sql --<--<--

