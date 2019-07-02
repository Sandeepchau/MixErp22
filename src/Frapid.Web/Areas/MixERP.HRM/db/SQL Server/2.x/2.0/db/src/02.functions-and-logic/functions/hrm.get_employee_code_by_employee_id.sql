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
