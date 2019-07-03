using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class PriceTypeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/price-types")]
        [MenuPolicy]
        [AccessPolicy("sales", "price_types", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/PriceTypes.cshtml", this.Tenant));
        }
    }
}