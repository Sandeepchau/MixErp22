using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Inventory.Controllers.Backend
{
    public class HomeController:InventoryBackendController
    {
        [Route("dashboard/inventory/home")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Home/Index.cshtml", this.Tenant));
        }
    }
}