using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class EmploymentStatusCodeController : DashboardController
    {
        [MenuPolicy]
        [ScrudFactory]
        [Route("dashboard/hrm/setup/employment-status-codes")]
        [AccessPolicy("hrm", "employment_status_codes", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            var result = this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/EmploymentStatusCodes/Index.cshtml", this.Tenant));
            return result;
        }
    }
}