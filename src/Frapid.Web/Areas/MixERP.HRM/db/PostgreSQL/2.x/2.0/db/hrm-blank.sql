-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
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

DROP SCHEMA IF EXISTS hrm CASCADE;
CREATE SCHEMA hrm;

CREATE TABLE hrm.week_days
(
	week_day_id                 			integer NOT NULL CHECK(week_day_id>=1 AND week_day_id<=7) PRIMARY KEY,
	week_day_code               			national character varying(12) NOT NULL UNIQUE,
	week_day_name               			national character varying(50) NOT NULL UNIQUE,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX week_days_week_day_code_uix
ON hrm.week_days(UPPER(week_day_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX week_days_week_day_name_uix
ON hrm.week_days(UPPER(week_day_name))
WHERE NOT deleted;

CREATE TABLE hrm.identification_types
(
	identification_type_id					SERIAL PRIMARY KEY,
	identification_type_code                national character varying(12) NOT NULL,
	identification_type_name                national character varying(100) NOT NULL UNIQUE,
	can_expire                              boolean NOT NULL DEFAULT(false),
	audit_user_id                           integer NULL REFERENCES account.users,
	audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX identification_types_identification_type_code_uix
ON hrm.identification_types(UPPER(identification_type_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX identification_types_identification_type_name_uix
ON hrm.identification_types(UPPER(identification_type_name))
WHERE NOT deleted;

CREATE TABLE hrm.social_networks
(
	social_network_id                     	SERIAL PRIMARY KEY,
	social_network_name                     national character varying(128) NOT NULL,
	icon_css_class                      	national character varying(128),
	base_url                                national character varying(128) DEFAULT(''),
	audit_user_id                           integer NULL REFERENCES account.users,
	audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE TABLE hrm.departments
(
    department_id                           SERIAL PRIMARY KEY,
    department_code                         national character varying(12) NOT NULL,
    department_name                         national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX departments_department_code_uix
ON hrm.departments(UPPER(department_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX departments_department_name_uix
ON hrm.departments(UPPER(department_name))
WHERE NOT deleted;

CREATE TABLE hrm.roles
(
    role_id                           		SERIAL PRIMARY KEY,
    role_code                         		national character varying(12) NOT NULL,
    role_name                         		national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX roles_role_code_uix
ON hrm.roles(UPPER(role_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX roles_role_name_uix
ON hrm.roles(UPPER(role_name))
WHERE NOT deleted;

CREATE TABLE hrm.nationalities
(
	nationality_id							SERIAL PRIMARY KEY,
    nationality_code                        national character varying(12),
    nationality_name                        national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX nationalities_nationality_code_uix
ON hrm.nationalities(UPPER(nationality_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX nationalities_nationality_name_uix
ON hrm.nationalities(UPPER(nationality_name))
WHERE NOT deleted;

CREATE TABLE hrm.education_levels
(
    education_level_id                      SERIAL NOT NULL PRIMARY KEY,
    education_level_name                    national character varying(50) NOT NULL UNIQUE,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX education_levels_education_level_name
ON hrm.education_levels(UPPER(education_level_name))
WHERE NOT deleted;

CREATE TABLE hrm.employment_status_codes
(
    employment_status_code_id               integer NOT NULL PRIMARY KEY,
    status_code                             national character varying(12) NOT NULL UNIQUE,
    status_code_name                        national character varying(100) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX employment_status_codes_status_code_uix
ON hrm.employment_status_codes(UPPER(status_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX employment_status_codes_status_code_name_uix
ON hrm.employment_status_codes(UPPER(status_code_name))
WHERE NOT deleted;

CREATE TABLE hrm.employment_statuses
(
    employment_status_id                    SERIAL NOT NULL PRIMARY KEY,
    employment_status_code                  national character varying(12) NOT NULL UNIQUE,
    employment_status_name                  national character varying(100) NOT NULL,
    is_contract                             boolean NOT NULL DEFAULT(false),
    default_employment_status_code_id       integer NOT NULL REFERENCES hrm.employment_status_codes,
    description                             text DEFAULT(''),    
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX employment_statuses_employment_status_code_uix
ON hrm.employment_statuses(UPPER(employment_status_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX employment_statuses_employment_status_name_uix
ON hrm.employment_statuses(UPPER(employment_status_name))
WHERE NOT deleted;

CREATE TABLE hrm.job_titles
(
    job_title_id                            SERIAL NOT NULL PRIMARY KEY,
    job_title_code                          national character varying(12) NOT NULL UNIQUE,
    job_title_name                          national character varying(100) NOT NULL,
    description                             text DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX job_titles_job_title_code_uix
ON hrm.job_titles(UPPER(job_title_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX job_titles_job_title_name_uix
ON hrm.job_titles(UPPER(job_title_name))
WHERE NOT deleted;

CREATE TABLE hrm.pay_grades
(
    pay_grade_id                            SERIAL NOT NULL PRIMARY KEY,
    pay_grade_code                          national character varying(12) NOT NULL UNIQUE,
    pay_grade_name                          national character varying(100) NOT NULL,
    minimum_salary                          numeric(30, 6) NOT NULL,
    maximum_salary                          numeric(30, 6) NOT NULL
                                            CHECK(maximum_salary >= minimum_salary),
    description                             text DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX pay_grades_pay_grade_code_uix
ON hrm.pay_grades(UPPER(pay_grade_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX pay_grades_pay_grade_name_uix
ON hrm.pay_grades(UPPER(pay_grade_name))
WHERE NOT deleted;

CREATE TABLE hrm.shifts
(
    shift_id                            	SERIAL NOT NULL PRIMARY KEY,
    shift_code                          	national character varying(12) NOT NULL UNIQUE,
    shift_name                          	national character varying(100) NOT NULL,
    begins_from                         	time NOT NULL,
    ends_on                             	time NOT NULL,
    description                         	text DEFAULT(''),
    audit_user_id                       	integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX shifts_shift_code_uix
ON hrm.shifts(UPPER(shift_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX shifts_shift_name_uix
ON hrm.shifts(UPPER(shift_name))
WHERE NOT deleted;

CREATE TABLE hrm.leave_types
(
    leave_type_id                           SERIAL NOT NULL PRIMARY KEY,
    leave_type_code                         national character varying(12) NOT NULL UNIQUE,
    leave_type_name                         national character varying(100) NOT NULL,
    description                             text DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX leave_types_leave_type_code_uix
ON hrm.leave_types(UPPER(leave_type_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX leave_types_leave_type_name_uix
ON hrm.leave_types(UPPER(leave_type_name))
WHERE NOT deleted;

CREATE TABLE hrm.office_hours
(
    office_hour_id                          SERIAL NOT NULL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    shift_id                                integer NOT NULL REFERENCES hrm.shifts,
    week_day_id                             integer NOT NULL REFERENCES hrm.week_days,
    begins_from                             time NOT NULL,
    ends_on                                 time NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE TABLE hrm.leave_benefits
(
    leave_benefit_id                        SERIAL NOT NULL PRIMARY KEY,
    leave_benefit_code                      national character varying(12) NOT NULL UNIQUE,
    leave_benefit_name                      national character varying(128) NOT NULL,
    total_days                              public.integer_strict NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX leave_benefits_leave_benefit_code_uix
ON hrm.leave_benefits(UPPER(leave_benefit_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX leave_benefits_leave_benefit_name_uix
ON hrm.leave_benefits(UPPER(leave_benefit_name))
WHERE NOT deleted;

CREATE TABLE hrm.employee_types
(
    employee_type_id                        SERIAL NOT NULL PRIMARY KEY,
    employee_type_code                      national character varying(12) NOT NULL UNIQUE,
    employee_type_name                      national character varying(128) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX employee_types_employee_type_code_uix
ON hrm.employee_types(UPPER(employee_type_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX employee_types_employee_type_name_uix
ON hrm.employee_types(UPPER(employee_type_name))
WHERE NOT deleted;

CREATE TABLE hrm.employees
(
    employee_id                             SERIAL NOT NULL PRIMARY KEY,
    employee_code                           national character varying(12) NOT NULL UNIQUE,
    first_name                              national character varying(50) NOT NULL,
    middle_name                             national character varying(50) DEFAULT(''),
    last_name                               national character varying(50) DEFAULT(''),
    employee_name                           national character varying(160) NOT NULL,
    gender_code                             national character varying(4) NOT NULL 
                                            REFERENCES core.genders(gender_code),
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
    photo                                   public.photo,
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
    is_smoker                               boolean,
    is_alcoholic                            boolean,
    with_disabilities                       boolean,
    low_vision                              boolean,
    uses_wheelchair                         boolean,
    hard_of_hearing                         boolean,
    is_aphonic                              boolean,
    is_cognitively_disabled                 boolean,
    is_autistic                             boolean,
    service_ended_on                        date NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX employees_employee_code_uix
ON hrm.employees(UPPER(employee_code))
WHERE NOT deleted;

CREATE TABLE hrm.employee_identification_details
(
    employee_identification_detail_id       BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    identification_type_id                	integer NOT NULL REFERENCES hrm.identification_types,
    identification_number                   national character varying(128) NOT NULL,
    expires_on                              date,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)                                  
);

CREATE UNIQUE INDEX employee_identification_details_employee_id_itc_uix
ON hrm.employee_identification_details(employee_id, identification_type_id)
WHERE NOT deleted;

CREATE TABLE hrm.employee_social_network_details
(
    employee_social_network_detail_id       BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    social_network_id                     	integer NOT NULL REFERENCES hrm.social_networks,
    profile_link                       		national character varying(1000) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.contracts
(
    contract_id                             BIGSERIAL NOT NULL PRIMARY KEY,
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
    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.employee_experiences
(
    employee_experience_id                  BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    organization_name                       national character varying(128) NOT NULL,
    title                                   national character varying(128) NOT NULL,
    started_on                              date,
    ended_on                                date,
    details                                 text,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.employee_qualifications
(
    employee_qualification_id               BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    education_level_id                      integer NOT NULL REFERENCES hrm.education_levels,
    institution                             national character varying(128) NOT NULL,
    majors                                  national character varying(128) NOT NULL,
    total_years                             integer,
    score                                   numeric(30, 6),
    started_on                              date,
    completed_on                            date,
    details                                 text,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.leave_applications
(
    leave_application_id                    BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    leave_type_id                           integer NOT NULL REFERENCES hrm.leave_types,
    entered_by                              integer NOT NULL REFERENCES account.users,
    applied_on                              date DEFAULT(NOW()),
    reason                                  text,
    start_date                              date,
    end_date                                date,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.resignations
(
    resignation_id                          SERIAL NOT NULL PRIMARY KEY,
    entered_by                              integer NOT NULL REFERENCES account.users,
    notice_date                             date NOT NULL,
    desired_resign_date                     date NOT NULL,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    forward_to                              integer REFERENCES hrm.employees,
    reason                                  national character varying(128) NOT NULL,
    details                                 text,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE hrm.terminations
(
    termination_id                          SERIAL NOT NULL PRIMARY KEY,
    notice_date                             date NOT NULL,
    employee_id                             integer NOT NULL REFERENCES hrm.employees UNIQUE,
    forward_to                              integer REFERENCES hrm.employees,
    change_status_to                        integer NOT NULL REFERENCES hrm.employment_statuses,
    reason                                  national character varying(128) NOT NULL,
    details                                 text,
    service_end_date                        date NOT NULL,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
    
);

CREATE TABLE hrm.exit_types
(
    exit_type_id                            SERIAL NOT NULL PRIMARY KEY,
    exit_type_code                          national character varying(12) NOT NULL UNIQUE,
    exit_type_name                          national character varying(128) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX exit_types_exit_type_code_uix
ON hrm.exit_types(exit_type_code)
WHERE NOT deleted;

CREATE UNIQUE INDEX exit_types_exit_type_name_uix
ON hrm.exit_types(exit_type_name)
WHERE NOT deleted;

CREATE TABLE hrm.exits
(
    exit_id                                 BIGSERIAL NOT NULL PRIMARY KEY,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    forward_to                              integer REFERENCES hrm.employees,
    change_status_to                        integer NOT NULL REFERENCES hrm.employment_statuses,
    exit_type_id                            integer NOT NULL REFERENCES hrm.exit_types,
    exit_interview_details                  text,
    reason                                  national character varying(128) NOT NULL,
    details                                 text,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses,
    verified_by_user_id                     integer REFERENCES account.users,
    verified_on                             date,
    verification_reason                     national character varying(128) NULL,
    service_end_date                        date NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,    
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE TABLE hrm.attendances
(
    attendance_id                           BIGSERIAL NOT NULL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    employee_id                             integer NOT NULL REFERENCES hrm.employees,
    attendance_date                         date NOT NULL,
    was_present                             boolean NOT NULL,
    check_in_time                           time NULL,
    check_out_time                          time NULL,
    overtime_hours                          numeric(30, 6) NOT NULL,
    was_absent                              boolean NOT NULL CHECK(was_absent != was_present),
    reason_for_absenteeism                  text,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX attendance_date_employee_id_uix
ON hrm.attendances(attendance_date, employee_id)
WHERE NOT deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_by_employee_id.sql --<--<--
DROP FUNCTION IF EXISTS hrm.get_employee_by_employee_id(_employee_id integer);

CREATE FUNCTION hrm.get_employee_by_employee_id(_employee_id integer)
RETURNS text
STABLE
AS
$$
BEGIN
    RETURN
        employee_code || ' (' || employee_name || ')'      
    FROM hrm.employees
    WHERE hrm.employees.employee_id = $1
    AND NOT hrm.employees.deleted;    
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_code_by_employee_id.sql --<--<--
DROP FUNCTION IF EXISTS hrm.get_employee_code_by_employee_id(_employee_id integer);

CREATE FUNCTION hrm.get_employee_code_by_employee_id(_employee_id integer)
RETURNS text
STABLE
AS
$$
BEGIN
    RETURN
        employee_code
    FROM hrm.employees
    WHERE hrm.employees.employee_id = $1
    AND NOT hrm.employees.deleted;    
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/02.functions-and-logic/functions/hrm.get_employee_name_by_employee_id.sql --<--<--
DROP FUNCTION IF EXISTS hrm.get_employee_name_by_employee_id(_employee_id integer);

CREATE FUNCTION hrm.get_employee_name_by_employee_id(_employee_id integer)
RETURNS text
STABLE
AS
$$
BEGIN
    RETURN
        employee_name
    FROM hrm.employees
    WHERE hrm.employees.employee_id = $1
    AND NOT hrm.employees.deleted;    
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/02.functions-and-logic/triggers/employee_dismissal.sql --<--<--
DROP FUNCTION IF EXISTS hrm.dismiss_employee() CASCADE;

CREATE FUNCTION hrm.dismiss_employee()
RETURNS trigger
AS
$$
    DECLARE _service_end        date;
    DECLARE _new_status_id      integer;
BEGIN
    IF(hstore(NEW) ? 'change_status_to') THEN
        _new_status_id := NEW.change_status_to;
    END IF;

    IF(hstore(NEW) ? 'service_end_date') THEN
        _service_end := NEW.service_end_date;
    END IF;

    IF(_service_end = NULL) THEN
        IF(hstore(NEW) ? 'desired_resign_date') THEN
            _service_end := NEW.desired_resign_date;
        END IF;
    END IF;
    
    IF(NEW.verification_status_id > 0) THEN        
        UPDATE hrm.employees
        SET
            service_ended_on = _service_end
        WHERE employee_id = NEW.employee_id;

        IF(_new_status_id IS NOT NULL) THEN
            UPDATE hrm.employees
            SET
                current_employment_status_id = _new_status_id
            WHERE employee_id = NEW.employee_id;
        END IF;        
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS hrm.undismiss_employee() CASCADE;

CREATE FUNCTION hrm.undismiss_employee()
RETURNS trigger
AS
$$
BEGIN
    UPDATE hrm.employees
    SET
        service_ended_on = NULL
    WHERE employee_id = OLD.employee_id;

    RETURN OLD;    
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER dismiss_employee_trigger BEFORE INSERT OR UPDATE ON hrm.resignations FOR EACH ROW EXECUTE PROCEDURE hrm.dismiss_employee();
CREATE TRIGGER dismiss_employee_trigger BEFORE INSERT OR UPDATE ON hrm.terminations FOR EACH ROW EXECUTE PROCEDURE hrm.dismiss_employee();
CREATE TRIGGER dismiss_employee_trigger BEFORE INSERT OR UPDATE ON hrm.exits FOR EACH ROW EXECUTE PROCEDURE hrm.dismiss_employee();

CREATE TRIGGER undismiss_employee_trigger BEFORE DELETE ON hrm.resignations FOR EACH ROW EXECUTE PROCEDURE hrm.undismiss_employee();
CREATE TRIGGER undismiss_employee_trigger BEFORE DELETE ON hrm.terminations FOR EACH ROW EXECUTE PROCEDURE hrm.undismiss_employee();
CREATE TRIGGER undismiss_employee_trigger BEFORE DELETE ON hrm.exits FOR EACH ROW EXECUTE PROCEDURE hrm.undismiss_employee();

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/03.menus/menus.sql --<--<--
SELECT * FROM core.create_app('MixERP.HRM', 'HRM', 'HRM', '1.0', 'MixERP Inc.', 'December 1, 2015', 'user yellow', '/dashboard/hrm/tasks/employees', null);

SELECT * FROM core.create_menu('MixERP.HRM', 'Tasks',  'Tasks', '', 'tasks icon', '');
SELECT * FROM core.create_menu('MixERP.HRM', 'Attendance', 'Attendance', '/dashboard/hrm/tasks/attendance', 'check square', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'Employees', 'Employees', '/dashboard/hrm/tasks/employees', 'users', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'Contracts', 'Contracts', '/dashboard/hrm/tasks/contracts', 'write', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'LeaveApplications', 'Leave Applications', '/dashboard/hrm/tasks/leave-applications', 'share square', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'Resignations', 'Resignations', '/dashboard/hrm/tasks/resignations', 'remove user', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'Terminations', 'Terminations', '/dashboard/hrm/tasks/terminations', 'remove circle', 'Tasks');
SELECT * FROM core.create_menu('MixERP.HRM', 'Exits', 'Exits', '/dashboard/hrm/tasks/exits', 'remove circle outline', 'Tasks');

SELECT * FROM core.create_menu('MixERP.HRM', 'Verification', 'Verification', '', 'check circle', '');
SELECT * FROM core.create_menu('MixERP.HRM', 'VerifyContracts', 'Verify Contracts', '/dashboard/hrm/verification/contracts', 'write square', 'Verification');
SELECT * FROM core.create_menu('MixERP.HRM', 'VerifyLeaveApplications', 'Verify Leave Applications', '/dashboard/hrm/verification/leave-applications', 'checked calendar', 'Verification');
SELECT * FROM core.create_menu('MixERP.HRM', 'VerifyResignations', 'Verify Resignations', '/dashboard/hrm/verification/resignations', 'mail forward', 'Verification');
SELECT * FROM core.create_menu('MixERP.HRM', 'VerifyTerminations', 'Verify Terminations', '/dashboard/hrm/verification/terminations', 'erase', 'Verification');
SELECT * FROM core.create_menu('MixERP.HRM', 'VerifyExits', 'Verify Exits', '/dashboard/hrm/verification/exits', 'send', 'Verification');

SELECT * FROM core.create_menu('MixERP.HRM', 'SetupAndConfiguration', 'Setup & Configuration', '', 'configure', '');
SELECT * FROM core.create_menu('MixERP.HRM', 'EmploymentStatuses', 'Employment Statuses', '/dashboard/hrm/setup/employment-statuses', 'info', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'IdentificationTypes', 'Identification Types', '/dashboard/hrm/setup/identification-types', 'child', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'EmployeeTypes', 'Employee Types', '/dashboard/hrm/setup/employee-types', 'child', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'EducationLevels', 'Education Levels', '/dashboard/hrm/setup/education-levels', 'student', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'JobTitles', 'Job Titles', '/dashboard/hrm/setup/job-titles', 'suitcase', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'PayGrades', 'Pay Grades', '/dashboard/hrm/setup/pay-grades', 'payment', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'Shifts', 'Shifts', '/dashboard/hrm/setup/shifts', 'paw', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'OfficeHours', 'Office Hours', '/dashboard/hrm/setup/office-hours', 'alarm outline', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'LeaveTypes', 'Leave Types', '/dashboard/hrm/setup/leave-types', 'hotel', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'LeaveBenefits', 'Leave Benefits', '/dashboard/hrm/setup/leave-benefits', 'car', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'ExitTypes', 'Exit Types', '/dashboard/hrm/setup/exit-types', 'remove', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'SocialNetworks', 'Social Networks', '/dashboard/hrm/setup/social-networks', 'users', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'Nationalities', 'Nationalities', '/dashboard/hrm/setup/nationalities', 'flag', 'Setup & Configuration');
SELECT * FROM core.create_menu('MixERP.HRM', 'MaritalStatuses', 'Marital Statuses', '/dashboard/hrm/setup/marital-statuses', 'smile', 'Setup & Configuration');


SELECT * FROM core.create_menu('MixERP.HRM', 'Reports', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('MixERP.HRM', 'Attendances', 'Attendances', '/dashboard/hrm/reports/attendances', 'bullseye', 'Reports');



SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.HRM',
    '{*}'::text[]
);


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/04.default-values/01.default-values.sql --<--<--
INSERT INTO hrm.identification_types(identification_type_code, identification_type_name, can_expire)
SELECT 'SSN', 'Social Security Number', false UNION ALL
SELECT 'DLN', 'Driving License Number', true;



-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.contract_scrud_view.sql --<--<--
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

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.contract_verification_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.contract_verification_scrud_view;

CREATE VIEW hrm.contract_verification_scrud_view
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
WHERE verification_status_id = 0
AND NOT hrm.contracts.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employee_experience_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_experience_scrud_view;

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
WHERE NOT hrm.employee_experiences.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employee_identification_detail_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_identification_detail_scrud_view;

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
WHERE NOT hrm.employee_identification_details.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employee_qualification_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_qualification_scrud_view;

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
WHERE NOT hrm.employee_qualifications.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employee_social_network_detail_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_social_network_detail_scrud_view;

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
WHERE NOT hrm.employee_social_network_details.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employee_type_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_type_scrud_view;

CREATE VIEW hrm.employee_type_scrud_view
AS
SELECT
    employee_type_id,
    employee_type_code,
    employee_type_name
FROM hrm.employee_types
WHERE NOT hrm.employee_types.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.employment_status_code_selector_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employment_status_code_selector_view;

CREATE VIEW hrm.employment_status_code_selector_view
AS
SELECT
    hrm.employment_status_codes.employment_status_code_id,
    hrm.employment_status_codes.status_code || ' (' || hrm.employment_status_codes.status_code_name || ')' AS employment_status_code_name
FROM hrm.employment_status_codes
WHERE NOT hrm.employment_status_codes.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.exit_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.exit_scrud_view;

CREATE VIEW hrm.exit_scrud_view
AS
SELECT
    hrm.exits.exit_id,
    hrm.exits.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    hrm.exits.reason,
    forwarded_to.employee_code || ' (' || forwarded_to.employee_name || ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code || ' (' || hrm.employment_statuses.employment_status_name || ')' AS employment_status,
    hrm.exit_types.exit_type_code || ' (' || hrm.exit_types.exit_type_name || ')' AS exit_type,
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
AND NOT hrm.exits.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.exit_verification_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.exit_verification_scrud_view;

CREATE VIEW hrm.exit_verification_scrud_view
AS
SELECT
    hrm.exits.exit_id,
    hrm.exits.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    hrm.exits.reason,
    forwarded_to.employee_code || ' (' || forwarded_to.employee_name || ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code || ' (' || hrm.employment_statuses.employment_status_name || ')' AS employment_status,
    hrm.exit_types.exit_type_code || ' (' || hrm.exit_types.exit_type_name || ')' AS exit_type,
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
AND NOT hrm.exits.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.leave_application_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.leave_application_scrud_view;

CREATE VIEW hrm.leave_application_scrud_view
AS
SELECT
    hrm.leave_applications.leave_application_id,
    hrm.leave_applications.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.leave_types.leave_type_code || ' (' || hrm.leave_types.leave_type_name || ')' AS leave_type,
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
WHERE NOT hrm.leave_applications.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.leave_application_verification_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.leave_application_verification_scrud_view;

CREATE VIEW hrm.leave_application_verification_scrud_view
AS
SELECT
    hrm.leave_applications.leave_application_id,
    hrm.leave_applications.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    hrm.leave_types.leave_type_code || ' (' || hrm.leave_types.leave_type_name || ')' AS leave_type,
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
AND NOT hrm.leave_applications.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.office_hour_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.office_hour_scrud_view;

CREATE VIEW hrm.office_hour_scrud_view
AS
SELECT
    hrm.office_hours.office_hour_id,
    core.offices.office_code || ' (' || core.offices.office_name || ')' AS office,
    core.offices.logo as photo,
    hrm.shifts.shift_code || ' (' || hrm.shifts.shift_name || ')' AS shift,
    hrm.week_days.week_day_code || ' (' || hrm.week_days.week_day_name || ')' AS week_day,
    hrm.office_hours.begins_from,
    hrm.office_hours.ends_on
FROM hrm.office_hours
LEFT JOIN core.offices
ON core.offices.office_id = hrm.office_hours.office_id
LEFT JOIN hrm.shifts
ON hrm.shifts.shift_id = hrm.office_hours.shift_id
LEFT JOIN hrm.week_days
ON hrm.week_days.week_day_id = hrm.office_hours.week_day_id
WHERE NOT hrm.office_hours.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.resignation_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.resignation_scrud_view;

CREATE VIEW hrm.resignation_scrud_view
AS
SELECT
    hrm.resignations.resignation_id,
    account.users.name AS entered_by,
    hrm.resignations.notice_date,
    hrm.resignations.desired_resign_date,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    forward_to.employee_code || ' (' || forward_to.employee_name || ')' AS forward_to,
    hrm.resignations.reason
FROM hrm.resignations
INNER JOIN account.users
ON account.users.user_id = hrm.resignations.entered_by
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.resignations.employee_id
INNER JOIN hrm.employees AS forward_to
ON forward_to.employee_id = hrm.resignations.forward_to
WHERE NOT hrm.resignations.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.resignation_verification_view.sql --<--<--
DROP VIEW IF EXISTS hrm.resignation_verification_scrud_view;

CREATE VIEW hrm.resignation_verification_scrud_view
AS
SELECT
    hrm.resignations.resignation_id,
    account.users.name AS entered_by,
    hrm.resignations.notice_date,
    hrm.resignations.desired_resign_date,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    forward_to.employee_code || ' (' || forward_to.employee_name || ')' AS forward_to,
    hrm.resignations.reason
FROM hrm.resignations
INNER JOIN account.users
ON account.users.user_id = hrm.resignations.entered_by
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.resignations.employee_id
INNER JOIN hrm.employees AS forward_to
ON forward_to.employee_id = hrm.resignations.forward_to
WHERE verification_status_id = 0
AND NOT hrm.resignations.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.termination_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.termination_scrud_view;

CREATE VIEW hrm.termination_scrud_view
AS
SELECT
    hrm.terminations.termination_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    hrm.terminations.notice_date,
    hrm.terminations.service_end_date,
    forwarded_to.employee_code || ' (' || forwarded_to.employee_name || ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code || ' (' || hrm.employment_statuses.employment_status_name || ')' AS employment_status,
    hrm.terminations.reason,
    hrm.terminations.details
FROM hrm.terminations
INNER JOIN hrm.employees
ON hrm.employees.employee_id = hrm.terminations.employee_id
INNER JOIN hrm.employment_statuses
ON hrm.employment_statuses.employment_status_id = hrm.terminations.change_status_to
INNER JOIN hrm.employees AS forwarded_to
ON forwarded_to.employee_id = hrm.terminations.forward_to
WHERE NOT hrm.terminations.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.scrud-views/hrm.termination_verification_scrud_view.sql --<--<--
DROP VIEW IF EXISTS hrm.termination_verification_scrud_view;

CREATE VIEW hrm.termination_verification_scrud_view
AS
SELECT
    hrm.terminations.termination_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
    hrm.employees.photo,
    hrm.terminations.notice_date,
    hrm.terminations.service_end_date,
    forwarded_to.employee_code || ' (' || forwarded_to.employee_name || ' )' AS forward_to,
    hrm.employment_statuses.employment_status_code || ' (' || hrm.employment_statuses.employment_status_name || ')' AS employment_status,
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
AND NOT hrm.terminations.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.selector-views/hrm.status_code_view.sql --<--<--
DROP VIEW IF EXISTS hrm.status_code_view;

CREATE VIEW hrm.status_code_view
AS
SELECT
	hrm.employment_status_codes.employment_status_code_id AS status_code_id,
	hrm.employment_status_codes.status_code,
	hrm.employment_status_codes.status_code_name
FROM hrm.employment_status_codes
WHERE NOT hrm.employment_status_codes.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.views/hrm.attendance_view.sql --<--<--
DROP VIEW IF EXISTS hrm.attendance_view;

CREATE VIEW hrm.attendance_view
AS
SELECT
    hrm.attendances.attendance_id,
    hrm.attendances.office_id,
    core.offices.office_code || ' (' || core.offices.office_name || ')' AS office,
    hrm.attendances.employee_id,
    hrm.employees.employee_code || ' (' || hrm.employees.employee_name || ')' AS employee,
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
AND NOT hrm.attendances.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/05.views/hrm.employee_view.sql --<--<--
DROP VIEW IF EXISTS hrm.employee_view;

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
    core.marital_statuses.marital_status_code || ' (' || core.marital_statuses.marital_status_name || ')' AS marital_status,
    hrm.employees.joined_on,
    hrm.employees.office_id,
    core.offices.office_code || ' (' || core.offices.office_name || ')' AS office,
    hrm.employees.user_id,
    account.users.name,
    hrm.employees.employee_type_id,
    hrm.employee_types.employee_type_code || ' (' || hrm.employee_types.employee_type_name || ')' AS employee_type,
    hrm.employees.current_department_id,
    hrm.departments.department_code || ' (' || hrm.departments.department_name || ')' AS current_department,    
    hrm.employees.current_role_id,
    hrm.roles.role_code || ' (' || hrm.roles.role_name || ')' AS role,
    hrm.employees.current_employment_status_id,
    hrm.employment_statuses.employment_status_code || ' (' || employment_status_name || ')' AS employment_status,
    hrm.employees.current_job_title_id,
    hrm.job_titles.job_title_code || ' (' || hrm.job_titles.job_title_name || ')' AS job_title,
    hrm.employees.current_pay_grade_id,
    hrm.pay_grades.pay_grade_code || ' (' || hrm.pay_grades.pay_grade_name || ')' AS pay_grade,
    hrm.employees.current_shift_id,
    hrm.shifts.shift_code || ' (' || hrm.shifts.shift_name || ')' AS shift,
    hrm.employees.nationality_id,
    hrm.nationalities.nationality_code || ' (' || hrm.nationalities.nationality_name || ')' AS nationality,
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
INNER JOIN core.genders
ON hrm.employees.gender_code = core.genders.gender_code
INNER JOIN core.marital_statuses
ON hrm.employees.marital_status_id = core.marital_statuses.marital_status_id
INNER JOIN core.offices
ON hrm.employees.office_id = core.offices.office_id
INNER JOIN hrm.departments
ON hrm.employees.current_department_id = hrm.departments.department_id
INNER JOIN hrm.employee_types
ON hrm.employee_types.employee_type_id = hrm.employees.employee_type_id
INNER JOIN hrm.employment_statuses
ON hrm.employees.current_employment_status_id = hrm.employment_statuses.employment_status_id
INNER JOIN hrm.job_titles
ON hrm.employees.current_job_title_id = hrm.job_titles.job_title_id
INNER JOIN hrm.pay_grades
ON hrm.employees.current_pay_grade_id = hrm.pay_grades.pay_grade_id
INNER JOIN hrm.shifts
ON hrm.employees.current_shift_id = hrm.shifts.shift_id
LEFT JOIN account.users
ON hrm.employees.user_id = account.users.user_id
LEFT JOIN hrm.roles
ON hrm.employees.current_role_id = hrm.roles.role_id
LEFT JOIN hrm.nationalities
ON hrm.employees.nationality_id = hrm.nationalities.nationality_id
LEFT JOIN core.countries
ON hrm.employees.country_code = core.countries.country_code
WHERE (service_ended_on IS NULL OR COALESCE(service_ended_on, 'infinity') >= NOW())
AND NOT hrm.employees.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/99.ownership.sql --<--<--
DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.schemaname || '.' || this.tablename ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.mat_view ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
    DECLARE _version_number integer = current_setting('server_version_num')::integer;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    IF(_version_number < 110000) THEN
        FOR this IN 
        SELECT 'ALTER '
            || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    ELSE
        FOR this IN 
        SELECT 'ALTER '
            || CASE p.prokind WHEN 'a' THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    END IF;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER VIEW '|| this.schemaname || '.' || this.viewname ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO frapid_db_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT      'ALTER TYPE ' || n.nspname || '.' || t.typname || ' OWNER TO frapid_db_user;' AS sql
    FROM        pg_type t 
    LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
    WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
    AND         NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND         typtype NOT IN ('b')
    AND         n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.schemaname || '.' || this.tablename ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.mat_view  ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
    DECLARE _version_number integer = current_setting('server_version_num')::integer;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    IF(_version_number < 110000) THEN
        FOR this IN 
        SELECT 'GRANT EXECUTE ON '
            || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    ELSE
        FOR this IN 
        SELECT 'GRANT EXECUTE ON '
            || CASE p.prokind WHEN 'a' THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
            || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
        FROM   pg_catalog.pg_proc p
        JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
        LOOP        
            EXECUTE this.sql;
        END LOOP;
    END IF;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON '|| this.schemaname || '.' || this.viewname ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT USAGE ON SCHEMA ' || nspname || ' TO report_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/PostgreSQL/2.x/2.0/db/src/99.sample/kanban.sql --<--<--
DO
$$
    DECLARE objects text[];
    DECLARE users int[];
    DECLARE _user_id int;
    DECLARE _obj text;
BEGIN
    SELECT array_agg(user_id)
        INTO users
    FROM account.users INNER JOIN account.roles ON account.users.role_id = account.roles.role_id;

    objects := array[
        'hrm.employees', 
        'hrm.employment_statuses',
        'hrm.salaries',
        'hrm.wage_setup',
        'hrm.employee_type_scrud_view',
        'hrm.employee_identification_detail_scrud_view',
        'hrm.employee_social_network_detail_scrud_view',
        'hrm.employee_experience_scrud_view',
        'hrm.employee_qualification_scrud_view',
        'hrm.employee_wage_scrud_view',
        'hrm.leave_application_scrud_view',
        'hrm.contract_scrud_view',
        'hrm.exit_scrud_view',
        'hrm.education_levels',
        'hrm.job_titles',
        'hrm.pay_grades',
        'hrm.salary_types',
        'hrm.shifts',
        'hrm.office_hour_scrud_view',
        'hrm.leave_types',
        'hrm.leave_benefits',
        'hrm.exit_types',
        ''
        
        
        ];

    IF(_user_id IS NULL) THEN
        RETURN;
    END IF;

    FOREACH _user_id IN ARRAY users
    LOOP
        FOREACH _obj IN ARRAY objects
        LOOP
            PERFORM core.create_kanban(_obj, _user_id, 'Checklist');
            PERFORM core.create_kanban(_obj, _user_id, 'High Priority');
            PERFORM core.create_kanban(_obj, _user_id, 'Done');
        END LOOP;
    END LOOP;
END
$$
LANGUAGE plpgsql;
