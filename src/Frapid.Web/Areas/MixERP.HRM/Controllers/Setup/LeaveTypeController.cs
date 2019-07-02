using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class LeaveTypeController : DashboardController
    {
        [Route("dashboard/hrm/setup/leave-types")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "leave_types", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/LeaveTypes/Index.cshtml", this.Tenant));
        }
    }
}