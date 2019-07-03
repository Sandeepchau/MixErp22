using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CustomerController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/customers")]
        [MenuPolicy]
        [AccessPolicy("inventory", "customers", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Customers.cshtml", this.Tenant));
        }
    }
}