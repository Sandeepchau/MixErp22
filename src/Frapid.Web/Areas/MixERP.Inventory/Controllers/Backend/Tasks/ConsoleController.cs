using System.Web.Mvc;

namespace MixERP.Inventory.Controllers.Backend.Tasks
{
    public sealed class ConsoleController : InventoryBackendController
    {
        [Route("dashboard/inventory/tasks/console")]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Console/Index.cshtml", this.Tenant));
        }
    }
}