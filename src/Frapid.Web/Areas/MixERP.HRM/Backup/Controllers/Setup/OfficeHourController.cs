using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class OfficeHourController : DashboardController
    {
        [Route("dashboard/hrm/setup/office-hours")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "office_hours", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/OfficeHours/Index.cshtml", this.Tenant));
        }
    }
}