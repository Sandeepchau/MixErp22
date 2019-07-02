using System.Threading.Tasks;
using System.Web.Mvc;

namespace MixERP.Inventory.Controllers.Backend.Services
{
    public class UnitController : InventoryBackendController
    {
        [Route("dashboard/inventory/get-associated-units/{*itemCode}")]
        public async Task<ActionResult> IndexAsync(string itemCode)
        {
            var model = await DAL.Backend.Service.Units.GetAssociatedUnitsAsync(this.Tenant, itemCode).ConfigureAwait(true);
            return this.Ok(model);
        }
    }
}