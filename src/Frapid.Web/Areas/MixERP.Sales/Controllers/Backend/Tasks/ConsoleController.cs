using System.Web.Mvc;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public sealed class ConsoleController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/console")]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Console/Index.cshtml", this.Tenant));
        }
    }
}