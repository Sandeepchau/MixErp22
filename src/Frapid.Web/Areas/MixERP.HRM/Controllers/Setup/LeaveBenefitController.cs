using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class LeaveBenefitController : DashboardController
    {
        [Route("dashboard/hrm/setup/leave-benefits")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "leave_benefits", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/LeaveBenefits/Index.cshtml", this.Tenant));
        }
    }
}