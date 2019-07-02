using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class EmployeeSocialNetworks
    {
        public static async Task<IEnumerable<EmployeeSocialNetworkDetailScrudView>> GetSocialNetworksAsync(string tenant, int employeeId)
        {
            const string sql = "SELECT * FROM hrm.employee_social_network_detail_scrud_view WHERE employee_id=@0";
            return await Factory.GetAsync<EmployeeSocialNetworkDetailScrudView>(tenant, sql, employeeId).ConfigureAwait(false);
        }
    }
}