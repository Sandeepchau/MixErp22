using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class DepartmentController : DashboardController
    {
        [MenuPolicy]
        [ScrudFactory]
        [Route("dashboard/hrm/setup/departments")]
        [AccessPolicy("hrm", "departments", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            var result = this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Departments/Index.cshtml", this.Tenant));
            return result;
        }
    }
}