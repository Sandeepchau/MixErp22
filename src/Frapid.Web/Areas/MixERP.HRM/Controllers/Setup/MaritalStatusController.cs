using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class MaritalStatusController : DashboardController
    {
        [Route("dashboard/hrm/setup/marital-statuses")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("core", "marital_statuses", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/MaritalStatuses/Index.cshtml", this.Tenant));
        }
    }
}