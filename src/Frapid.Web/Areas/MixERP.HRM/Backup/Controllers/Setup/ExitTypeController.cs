using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class ExitTypeController : DashboardController
    {
        [Route("dashboard/hrm/setup/exit-types")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "exit_types", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ExitTypes/Index.cshtml", this.Tenant));
        }
    }
}