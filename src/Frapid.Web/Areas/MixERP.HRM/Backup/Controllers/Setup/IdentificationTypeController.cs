using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class IdentificationTypeController : DashboardController
    {
        [Route("dashboard/hrm/setup/identification-types")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "identification_types", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/IdentificationTypes/Index.cshtml", this.Tenant));
        }
    }
}