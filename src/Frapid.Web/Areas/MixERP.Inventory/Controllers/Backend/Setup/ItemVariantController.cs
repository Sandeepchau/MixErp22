using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard;
using MixERP.Inventory.DAL.Backend.Setup;
using MixERP.Inventory.DTO;
using Frapid.Areas.CSRF;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    [AntiForgery]
    public class ItemVariantController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/item-variants")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ItemVariants.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/setup/item-variants")]
        [MenuPolicy]
        [HttpPost]
        public async Task<ActionResult> PostAsync(ItemVariantInfo model)
        {
            try
            {
                int variantId = await ItemVariants.CreateAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(variantId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/inventory/setup/item-variants/{itemId}")]
        [MenuPolicy(OverridePath = "/dashboard/inventory/setup/item-variants")]
        [HttpDelete]
        public async Task<ActionResult> DeleteAsync(int itemId)
        {
            try
            {
                await ItemVariants.DeleteAsync(this.Tenant, itemId).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}