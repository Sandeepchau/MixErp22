using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Tasks
{
    public class LeaveApplicationController : DashboardController
    {
        [Route("dashboard/hrm/tasks/leave-applications")]
        [MenuPolicy]
        [AccessPolicy("hrm", "leave_applications", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/LeaveApplications/Index.cshtml", this.Tenant));
        }
    }
}