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
