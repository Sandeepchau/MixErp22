using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class PayGradeController : DashboardController
    {
        [Route("dashboard/hrm/setup/pay-grades")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "pay_grades", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/PayGrades/Index.cshtml", this.Tenant));
        }
    }
}