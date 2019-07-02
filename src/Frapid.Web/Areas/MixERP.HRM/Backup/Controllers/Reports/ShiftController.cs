using System.Web.Mvc;
using Frapid.Areas.Authorization;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;

namespace MixERP.HRM.Controllers.Reports
{
    public class AttendanceReportController : DashboardController
    {
        [Route("dashboard/hrm/reports/attendances")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Reports/Attendances/Index.cshtml", this.Tenant));
        }
    }
}