using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class ItemGroupController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/item-groups")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ItemGroups.cshtml", this.Tenant));
        }
    }
}