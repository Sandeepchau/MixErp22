using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class EmployeeExperiences
    {
        public static async Task<IEnumerable<EmployeeExperienceScrudView>> GetEmployeeExperiencesAsync(string tenant, int employeeId)
        {
            const string sql = "SELECT * FROM hrm.employee_experience_scrud_view WHERE employee_id=@0";
            return await Factory.GetAsync<EmployeeExperienceScrudView>(tenant, sql, employeeId).ConfigureAwait(false);
        }
    }
}