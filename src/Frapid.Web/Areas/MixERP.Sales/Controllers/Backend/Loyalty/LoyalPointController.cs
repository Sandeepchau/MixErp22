using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    public class LoyalPointController : SalesDashboardController
    {
        [Route("dashboard/sales/loyalty/points")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/Points/Index.cshtml", this.Tenant));
        }
    }
}