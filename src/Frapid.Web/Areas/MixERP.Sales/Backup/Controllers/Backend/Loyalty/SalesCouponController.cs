using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    public class SalesCouponController : SalesDashboardController
    {
        [Route("dashboard/sales/loyalty/coupons")]
        [MenuPolicy]
        [AccessPolicy("sales", "coupons", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/Coupons/Index.cshtml", this.Tenant));
        }
    }
}