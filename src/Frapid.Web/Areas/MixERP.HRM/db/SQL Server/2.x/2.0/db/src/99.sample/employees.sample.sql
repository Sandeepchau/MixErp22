INSERT INTO hrm.week_days(week_day_id, week_day_code, week_day_name)
SELECT  1,  'SUN',  'Sunday'    UNION ALL
SELECT  2,  'MON',  'Monday'    UNION ALL
SELECT  3,  'TUE',  'Tuesday'   UNION ALL
SELECT  4,  'WED',  'Wednesday' UNION ALL
SELECT  5,  'THU',  'Thursday'  UNION ALL
SELECT  6,  'FRI',  'Friday'    UNION ALL
SELECT  7,  'SAT',  'Saturday';
 

INSERT INTO core.offices(office_code, office_name)
SELECT 'BR', 'Branch Office';

INSERT INTO hrm.roles(role_code,role_name)
SELECT 'USER', 'Users'                  UNION ALL
SELECT 'EXEC', 'Executive'              UNION ALL
SELECT 'MNGR', 'Manager'                UNION ALL
SELECT 'SALE', 'Sales'                  UNION ALL
SELECT 'MARK', 'Marketing'              UNION ALL
SELECT 'LEGL', 'Legal & Compliance'     UNION ALL
SELECT 'FINC', 'Finance'                UNION ALL
SELECT 'HUMR', 'Human Resources'        UNION ALL
SELECT 'INFO', 'Information Technology' UNION ALL
SELECT 'CUST', 'Customer Service'       UNION ALL
SELECT 'ADM',  'Administration'         UNION ALL
SELECT 'BOD',   'Board of Directors';


INSERT INTO hrm.departments(department_code, department_name)
SELECT 'SAL', 'Sales & Billing'         UNION ALL
SELECT 'MKT', 'Marketing & Promotion'   UNION ALL
SELECT 'SUP', 'Support'                 UNION ALL
SELECT 'CC', 'Customer Care';

--The meaning of the following should not change
INSERT INTO hrm.employment_status_codes(employment_status_code_id, status_code, status_code_name)
SELECT -7, 'DEC', 'Deceased'                UNION ALL
SELECT -6, 'DEF', 'Defaulter'               UNION ALL
SELECT -5, 'TER', 'Terminated'              UNION ALL
SELECT -4, 'RES', 'Resigned'                UNION ALL
SELECT -3, 'EAR', 'Early Retirement'        UNION ALL
SELECT -2, 'RET', 'Normal Retirement'       UNION ALL
SELECT -1, 'CPO', 'Contract Period Over'    UNION ALL
SELECT  0, 'NOR', 'Normal Employment'       UNION ALL
SELECT  1, 'OCT', 'On Contract'             UNION ALL
SELECT  2, 'PER', 'Permanent Job'           UNION ALL
SELECT  3, 'RTG', 'Retiring';

INSERT INTO hrm.employment_statuses(employment_status_code, employment_status_name, default_employment_status_code_id, is_contract)
SELECT 'EMP', 'Employee',       0, 0 UNION ALL
SELECT 'INT', 'Intern',         1, 1 UNION ALL
SELECT 'CON', 'Contract Basis', 1, 1 UNION ALL
SELECT 'PER', 'Permanent',      2, 0;

INSERT INTO hrm.job_titles(job_title_code, job_title_name)
SELECT 'INT', 'Internship'                      UNION ALL
SELECT 'DEF', 'Default'                         UNION ALL
SELECT 'EXC', 'Executive'                       UNION ALL
SELECT 'MAN', 'Manager'                         UNION ALL
SELECT 'GEM', 'General Manager'                 UNION ALL
SELECT 'BME', 'Board Member'                    UNION ALL
SELECT 'CEO', 'Chief Executive Officer'         UNION ALL
SELECT 'CTO', 'Chief Technology Officer';

INSERT INTO hrm.pay_grades(pay_grade_code, pay_grade_name, minimum_salary, maximum_salary)
SELECT 'L-1', 'Level 1', 0, 0;

INSERT INTO hrm.shifts(shift_code, shift_name, begins_from, ends_on)
SELECT 'MOR', 'Morning Shift',  '6:00',   		'14:00'   UNION ALL
SELECT 'DAY', 'Day Shift',      '14:00',        '20:00'         UNION ALL
SELECT 'NIT', 'Night Shift',    '20:00',        '6:00';

INSERT INTO hrm.employee_types(employee_type_code, employee_type_name)
SELECT 'DEF', 'Default'                 UNION ALL
SELECT 'OUE', 'Outdoor Employees'       UNION ALL
SELECT 'PRO', 'Project Employees'       UNION ALL
SELECT 'SUP', 'Support Staffs'          UNION ALL
SELECT 'ENG', 'Engineers';

INSERT INTO hrm.leave_types(leave_type_code, leave_type_name)
SELECT 'NOR', 'Normal' UNION ALL
SELECT 'EME', 'Emergency' UNION ALL
SELECT 'ILL', 'Illness';

INSERT INTO hrm.exit_types(exit_type_code, exit_type_name)
SELECT 'COE', 'Contract Period Over' UNION ALL
SELECT 'RET', 'Retirement' UNION ALL
SELECT 'RES', 'Resignation' UNION ALL
SELECT 'TER', 'Termination' UNION ALL
SELECT 'DEC', 'Deceased';

INSERT INTO account.users(email, password, office_id, role_id, name, phone)
SELECT 'user@mixerp.com', '', 1, 1000, 'user', '';

INSERT INTO hrm.employees(employee_code, first_name, middle_name, last_name, employee_name, gender_code, marital_status_id, joined_on, office_id, user_id, employee_type_id, current_department_id, current_role_id, current_employment_status_id, current_job_title_id, current_pay_grade_id, current_shift_id, date_of_birth, photo, bank_account_number, bank_name, bank_branch_name)
SELECT 'MI-0001', 'Micheal', '', 'Paul', 'Paul, Micheal', 'M', '1', '2015-09-12', '2', '2', '1', '1', '1', '1', '1', '1', '2', '1997-07-01', '/dashboard/hrm/services/attachments/sample/man-838636_640.jpg', '1-2939-3944-03', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'AR-0001', 'Arjun', '', 'Rivers', 'Rivers, Arjun', 'M', '2', '2015-09-05', '2', '2', '2', '2', '2', '2', '2', '1', '2', '2006-11-04', '/dashboard/hrm/services/attachments/sample/beautiful-19075_640.jpg', '1-2939-3944-04', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'LA-0001', 'Lamar', '', 'Hull', 'Hull, Lamar', 'M', '3', '2015-09-24', '2', '2', '3', '3', '3', '3', '3', '1', '2', '1998-03-05', '/dashboard/hrm/services/attachments/sample/beautiful-653317_640.jpg', '1-2939-3944-05', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'BE-0001', 'Beau', '', 'Stokes', 'Stokes, Beau', 'M', '4', '2015-09-21', '2', '2', '4', '4', '4', '4', '4', '1', '2', '1982-09-20', '/dashboard/hrm/services/attachments/sample/beauty-20150_640.jpg', '1-2939-3944-06', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'KY-0001', 'Kyan', '', 'Barr', 'Barr, Kyan', 'M', '5', '2015-10-03', '2', '2', '5', '1', '5', '1', '5', '1', '2', '1978-10-21', '/dashboard/hrm/services/attachments/sample/beauty-739667_640.jpg', '1-2939-3944-07', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'AR-0002', 'Arturo', '', 'Newman', 'Newman, Arturo', 'M', '6', '2015-09-12', '2', '2', '1', '2', '6', '2', '6', '1', '2', '2001-10-16', '/dashboard/hrm/services/attachments/sample/brunette-15963_640.jpg', '1-2939-3944-08', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'MA-0001', 'Mateo', '', 'Mcdaniel', 'Mcdaniel, Mateo', 'F', '7', '2015-09-22', '2', '2', '2', '3', '7', '3', '7', '1', '2', '2013-12-13', '/dashboard/hrm/services/attachments/sample/businessman-805770_640.jpg', '1-2939-3944-09', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'LA-0002', 'Larry', '', 'Farmer', 'Farmer, Larry', 'F', '1', '2015-10-06', '2', '2', '3', '4', '8', '4', '8', '1', '2', '2001-03-23', '/dashboard/hrm/services/attachments/sample/chinese-572945_640.jpg', '1-2939-3944-10', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'BR-0001', 'Bryce', '', 'West', 'West, Bryce', 'M', '2', '2015-09-26', '2', '2', '4', '1', '9', '1', '1', '1', '2', '2012-09-18', '/dashboard/hrm/services/attachments/sample/cowboy-67630_640.jpg', '1-2939-3944-11', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'DA-0001', 'Dalton', '', 'Cunningham', 'Cunningham, Dalton', 'F', '3', '2015-10-02', '2', '2', '5', '2', '10', '2', '2', '1', '2', '1980-10-02', '/dashboard/hrm/services/attachments/sample/eyes-622355_640.jpg', '1-2939-3944-12', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'CH-0001', 'Chaz', '', 'Cote', 'Cote, Chaz', 'F', '4', '2015-10-02', '2', '2', '1', '3', '11', '3', '3', '1', '2', '1987-10-08', '/dashboard/hrm/services/attachments/sample/fairy-tales-636649_640.jpg', '1-2939-3944-13', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'SY-0001', 'Sydney', '', 'Holley', 'Holley, Sydney', 'F', '5', '2015-09-08', '2', '2', '2', '4', '12', '4', '4', '1', '2', '1978-03-02', '/dashboard/hrm/services/attachments/sample/friend-762590_640.jpg', '1-2939-3944-14', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'KA-0001', 'Karter', '', 'Barrera', 'Barrera, Karter', 'M', '6', '2015-10-01', '2', '2', '3', '1', '1', '1', '5', '1', '2', '1979-10-18', '/dashboard/hrm/services/attachments/sample/girl-102829_640.jpg', '1-2939-3944-15', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'GU-0001', 'Gunner', '', 'Moses', 'Moses, Gunner', 'M', '7', '2015-09-14', '2', '2', '4', '2', '2', '2', '6', '1', '2', '1991-12-01', '/dashboard/hrm/services/attachments/sample/girl-518321_640.jpg', '1-2939-3944-16', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'MA-0002', 'Marlon', '', 'Gates', 'Gates, Marlon', 'M', '1', '2015-09-11', '2', '2', '5', '3', '3', '3', '7', '1', '2', '1996-04-26', '/dashboard/hrm/services/attachments/sample/girl-518331_640.jpg', '1-2939-3944-17', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'FI-0001', 'Fisher', '', 'Velazquez', 'Velazquez, Fisher', 'M', '2', '2015-09-12', '2', '2', '1', '4', '4', '4', '8', '1', '2', '1982-01-20', '/dashboard/hrm/services/attachments/sample/girl-602177_640.jpg', '1-2939-3944-18', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'JA-0001', 'Jayce', '', 'Marsh', 'Marsh, Jayce', 'M', '3', '2015-08-31', '2', '2', '2', '1', '5', '1', '1', '1', '2', '1986-04-28', '/dashboard/hrm/services/attachments/sample/girl-637568_640.jpg', '1-2939-3944-19', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'BE-0002', 'Bernardo', '', 'Franks', 'Franks, Bernardo', 'M', '4', '2015-09-12', '2', '2', '3', '2', '6', '2', '2', '1', '2', '2003-10-01', '/dashboard/hrm/services/attachments/sample/girl-803179_640.jpg', '1-2939-3944-20', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'VI-0001', 'Victoria', '', 'Bland', 'Bland, Victoria', 'M', '5', '2015-10-01', '2', '2', '4', '3', '7', '3', '3', '1', '2', '1986-10-18', '/dashboard/hrm/services/attachments/sample/girl-846991_640.jpg', '1-2939-3944-21', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'LE-0001', 'Lewis', '', 'Farrell', 'Farrell, Lewis', 'M', '6', '2015-08-28', '2', '2', '5', '4', '8', '4', '4', '1', '2', '1981-11-08', '/dashboard/hrm/services/attachments/sample/girls-602168_640.jpg', '1-2939-3944-22', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'MA-0003', 'Maurice', '', 'Gibbs', 'Gibbs, Maurice', 'F', '7', '2015-10-10', '2', '2', '1', '1', '9', '1', '5', '1', '2', '1997-07-14', '/dashboard/hrm/services/attachments/sample/guy-549173_640.jpg', '1-2939-3944-23', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'LE-0002', 'Lee', '', 'Mueller', 'Mueller, Lee', 'F', '1', '2015-10-01', '2', '2', '2', '2', '10', '2', '6', '1', '2', '1986-11-30', '/dashboard/hrm/services/attachments/sample/indian-627831_640.jpg', '1-2939-3944-24', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'HA-0001', 'Hassan', '', 'Hendricks', 'Hendricks, Hassan', 'M', '2', '2015-09-21', '2', '2', '3', '3', '11', '3', '7', '1', '2', '1979-03-28', '/dashboard/hrm/services/attachments/sample/james-stewart-392932_640.jpg', '1-2939-3944-25', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'IS-0001', 'Isabella', '', 'Rankin', 'Rankin, Isabella', 'F', '3', '2015-09-22', '2', '2', '4', '4', '12', '4', '8', '1', '2', '2010-08-31', '/dashboard/hrm/services/attachments/sample/male-777913_640.jpg', '1-2939-3944-26', 'Bank of America', 'Myrtle Ave' UNION ALL
SELECT 'MA-0004', 'Matthias', '', 'Fitzpatrick', 'Fitzpatrick, Matthias', 'F', '4', '2015-10-06', '2', '2', '5', '1', '1', '1', '1', '1', '2', '1989-09-19', '/dashboard/hrm/services/attachments/sample/man-140547_640.jpg', '1-2939-3944-27', 'Bank of America', 'Myrtle Ave';



UPDATE hrm.employees
SET office_id = 1;

GO

