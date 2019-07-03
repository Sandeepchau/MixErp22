using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class PaymentTermController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/payment-terms")]
        [MenuPolicy]
        [AccessPolicy("sales", "payment_terms", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/PaymentTerms.cshtml", this.Tenant));
        }
    }
}