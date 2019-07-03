using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CustomerTypeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/customer-types")]
        [MenuPolicy]
        [AccessPolicy("inventory", "customer_types", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CustomerTypes.cshtml", this.Tenant));
        }
    }
}