using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Tasks
{
    public class ResignationController : DashboardController
    {
        [Route("dashboard/hrm/tasks/resignations")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "resignations", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Resignations/Index.cshtml", this.Tenant));
        }
    }
}