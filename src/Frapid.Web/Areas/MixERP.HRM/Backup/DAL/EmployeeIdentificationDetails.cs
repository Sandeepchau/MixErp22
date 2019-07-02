using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class EmployeeIdentificationDetails
    {
        public static async Task<IEnumerable<EmployeeIdentificationDetailScrudView>> GetEmployeeIdentificationsAsync(string tenant, int employeeId)
        {
            const string sql = "SELECT * FROM hrm.employee_identification_detail_scrud_view WHERE employee_id=@0";
            return await Factory.GetAsync<EmployeeIdentificationDetailScrudView>(tenant, sql, employeeId).ConfigureAwait(false);
        }
    }
}