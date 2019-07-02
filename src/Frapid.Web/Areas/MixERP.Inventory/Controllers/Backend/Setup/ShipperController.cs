using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class ShipperController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/shippers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Shippers.cshtml", this.Tenant));
        }
    }
}