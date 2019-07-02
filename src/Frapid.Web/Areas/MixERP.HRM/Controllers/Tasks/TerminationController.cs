using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Tasks
{
    public class TerminationController : DashboardController
    {
        [Route("dashboard/hrm/tasks/terminations")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "terminations", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Terminations/Index.cshtml", this.Tenant));
        }
    }
}