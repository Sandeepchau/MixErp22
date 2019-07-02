using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class UnitsOfMeasureController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/units-of-measure")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/UnitsOfMeasure.cshtml", this.Tenant));
        }
    }
}