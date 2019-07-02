﻿DROP FUNCTION IF EXISTS hrm.get_employee_code_by_employee_id(_employee_id integer);

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