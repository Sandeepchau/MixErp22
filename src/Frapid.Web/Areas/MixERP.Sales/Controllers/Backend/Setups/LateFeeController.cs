using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class LateFeeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/late-fee")]
        [MenuPolicy]
        [AccessPolicy("sales", "late_fee", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/LateFee.cshtml", this.Tenant));
        }
    }
}