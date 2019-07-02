using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Inventory.DAL.Backend.Tasks;
using MixERP.Inventory.QueryModels;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class AdjustmentController : InventoryBackendController
    {
        [Route("dashboard/inventory/tasks/inventory-adjustments")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Adjustment/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/tasks/inventory-adjustments/search")]
        [MenuPolicy(OverridePath = "/dashboard/inventory/tasks/inventory-adjustments")]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(AdjustmentSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await InventoryAdjustments.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/inventory/tasks/inventory-adjustments/verification")]
        [MenuPolicy]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Adjustment/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/tasks/adjustments/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/inventory/tasks/inventory-adjustments")]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Adjustment/Checklist.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/inventory/tasks/inventory-adjustments/new")]
        [MenuPolicy(OverridePath = "/dashboard/inventory/tasks/inventory-adjustments")]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Adjustment/New.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/tasks/inventory-adjustments/closing/{storeId}")]
        [MenuPolicy(OverridePath = "/dashboard/inventory/tasks/inventory-adjustments")]
        public async Task<ActionResult> GetClosingInventoryAsync(int storeId)
        {
            if (storeId <= 0)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var model = await Stores.GetClosingInventoryAsync(this.Tenant, storeId).ConfigureAwait(true);

            return this.Ok(model);
        }

        [Route("dashboard/inventory/tasks/inventory-adjustments")]
        [MenuPolicy]
        [HttpPost]
        public async Task<ActionResult> PostAsync(InventoryAdjustment model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            model.OfficeId = meta.OfficeId;
            model.UserId = meta.UserId;
            model.LoginId = meta.LoginId;

            try
            {
                long id = await InventoryAdjustments.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(id);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}