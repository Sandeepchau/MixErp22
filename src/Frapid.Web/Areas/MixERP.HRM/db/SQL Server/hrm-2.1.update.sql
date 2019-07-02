-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/03.menus/menus.sql --<--<--
EXECUTE core.create_menu 'MixERP.HRM', 'Departments', 'Departments', '/dashboard/hrm/setup/departments', 'smile', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'HRMRoles', 'HRM Roles', '/dashboard/hrm/setup/roles', 'smile', 'Setup & Configuration';
EXECUTE core.create_menu 'MixERP.HRM', 'EmployemntStatusCodes', 'Employemnt Status Codes', '/dashboard/hrm/setup/employment-status-codes', 'smile', 'Setup & Configuration';

-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/04.default-values/01.default-values.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/05.scrud-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/05.selector-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/05.views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/06.report-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.HRM/db/SQL Server/2.1.update/src/99.ownership.sql --<--<--
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

