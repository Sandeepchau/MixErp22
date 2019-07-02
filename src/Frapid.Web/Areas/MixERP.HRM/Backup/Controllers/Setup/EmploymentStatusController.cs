using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class EmploymentStatusController : DashboardController
    {
        [Route("dashboard/hrm/setup/employment-statuses")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "employment_statuses", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/EmploymentStatuses/Index.cshtml", this.Tenant));
        }
    }
}