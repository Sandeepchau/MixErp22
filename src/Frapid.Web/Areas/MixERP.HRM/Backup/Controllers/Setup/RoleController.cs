using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class RoleController : DashboardController
    {
        [MenuPolicy]
        [ScrudFactory]
        [Route("dashboard/hrm/setup/roles")]
        [AccessPolicy("hrm", "roles", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            var result = this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Roles/Index.cshtml", this.Tenant));
            return result;
        }
    }
}