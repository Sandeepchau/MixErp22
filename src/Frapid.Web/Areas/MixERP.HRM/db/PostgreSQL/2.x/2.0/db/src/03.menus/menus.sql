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
