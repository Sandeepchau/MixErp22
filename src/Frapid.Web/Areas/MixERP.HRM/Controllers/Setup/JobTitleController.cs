using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class JobTitleController : DashboardController
    {
        [Route("dashboard/hrm/setup/job-titles")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "job_titles", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/JobTitles/Index.cshtml", this.Tenant));
        }
    }
}