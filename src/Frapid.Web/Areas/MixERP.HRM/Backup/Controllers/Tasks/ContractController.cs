using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Tasks
{
    public class ContractController : DashboardController
    {
        [Route("dashboard/hrm/tasks/contracts")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "contracts", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Contracts/Index.cshtml", this.Tenant));
        }
    }
}