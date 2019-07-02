using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class EducationLevelController : DashboardController
    {
        [MenuPolicy]
        [ScrudFactory]
        [Route("dashboard/hrm/setup/education-levels")]
        [AccessPolicy("hrm", "education_levels", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            var result = this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/EducationLevels/Index.cshtml", this.Tenant));
            return result;
        }
    }
}