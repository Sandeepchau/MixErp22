using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class AttributeController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/attributes")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Attributes.cshtml", this.Tenant));
        }
    }
}