using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CashierController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/cashiers")]
        [MenuPolicy]
        [AccessPolicy("sales", "cashiers", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Cashiers.cshtml", this.Tenant));
        }
    }
}