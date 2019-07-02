using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class ItemTypeController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/item-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ItemTypes.cshtml", this.Tenant));
        }
    }
}