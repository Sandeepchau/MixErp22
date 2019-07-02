using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Tasks
{
    public class ExitController : DashboardController
    {
        [Route("dashboard/hrm/tasks/exits")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "exits", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Exits/Index.cshtml", this.Tenant));
        }
    }
}