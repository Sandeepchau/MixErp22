using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class EmployeeQualifications
    {
        public static async Task<IEnumerable<EmployeeQualificationScrudView>> GetQualificationsAsync(string tenant, int employeeId)
        {
            const string sql = "SELECT * FROM hrm.employee_qualification_scrud_view WHERE employee_id=@0";
            return await Factory.GetAsync<EmployeeQualificationScrudView>(tenant, sql, employeeId).ConfigureAwait(false);
        }
    }
}