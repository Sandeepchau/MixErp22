using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class Employees
    {
        public static async Task<EmployeeView> GetEmployeeAsync(string tenant, int employeeId)
        {
            const string sql = "SELECT * FROM hrm.employee_view WHERE employee_id=@0;";
            return (await Factory.GetAsync<EmployeeView>(tenant, sql, employeeId).ConfigureAwait(false)).FirstOrDefault();
        }

        public static async Task<IEnumerable<EmployeeView>> GetEmployeesAsync(string tenant, int officeId)
        {
            const string sql = "SELECT * FROM hrm.employee_view WHERE office_id=@0;";
            return await Factory.GetAsync<EmployeeView>(tenant, sql, officeId).ConfigureAwait(false);
        }
    }
}