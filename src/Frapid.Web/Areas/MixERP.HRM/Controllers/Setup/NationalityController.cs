using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class NationalityController : DashboardController
    {
        [Route("dashboard/hrm/setup/nationalities")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "nationalities", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Nationalities/Index.cshtml", this.Tenant));
        }
    }
}