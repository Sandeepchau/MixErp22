using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;

namespace MixERP.HRM.Controllers.Setup
{
    public class SocialNetworkController : DashboardController
    {
        [Route("dashboard/hrm/setup/social-networks")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "social_networks", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/SocialNetworks/Index.cshtml", this.Tenant));
        }
    }
}