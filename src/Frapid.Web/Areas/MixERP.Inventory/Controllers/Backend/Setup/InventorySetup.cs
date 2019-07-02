using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Inventory.DAL.Backend.Setup;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class InventorySetupController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/is")]
        [MenuPolicy]
        public async Task<ActionResult> Index()
        {
            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(true);
            var model = await InventorySetup.GetAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/IS.cshtml", this.Tenant), model);
        }

        [Route("dashboard/inventory/setup/is")]
        [MenuPolicy]
        [HttpPut]
        public async Task<ActionResult> Put(DTO.InventorySetup model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }


            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(true);

            if (!meta.IsAdministrator)
            {
                return this.AccessDenied();
            }


            try
            {
                await InventorySetup.SetAsync(this.Tenant, meta.OfficeId, model).ConfigureAwait(false);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}