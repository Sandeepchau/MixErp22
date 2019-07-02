using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class CompoundUnitsOfMeasureController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/compound-units-of-measure")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CompoundUnitsOfMeasure.cshtml", this.Tenant));
        }
    }
}