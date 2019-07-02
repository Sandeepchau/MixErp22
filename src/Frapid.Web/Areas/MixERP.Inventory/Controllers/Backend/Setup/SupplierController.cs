using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class SupplierController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/suppliers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Suppliers.cshtml", this.Tenant));
        }
    }
}