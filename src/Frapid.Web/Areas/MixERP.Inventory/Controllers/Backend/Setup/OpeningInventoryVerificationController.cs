using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.ViewModels;
using Frapid.Areas.CSRF;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    [AntiForgery]
    public class OpeningInventoryVerificationController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/opening-inventories/verification")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/OpeningInventory/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/setup/opening-inventories/verification/approve")]
        [HttpPost]
        public async Task<ActionResult> ApproveAsync(Verification model)
        {
            var appUser = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.OfficeId = appUser.OfficeId;
            model.UserId = appUser.UserId;
            model.LoginId = appUser.LoginId;
            model.VerificationStatusId = 2;

            try
            {
                long result = await Journals.VerifyTransactionAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/inventory/setup/opening-inventories/verification/reject")]
        [HttpPost]
        public async Task<ActionResult> RejectAsync(Verification model)
        {
            var appUser = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.OfficeId = appUser.OfficeId;
            model.UserId = appUser.UserId;
            model.LoginId = appUser.LoginId;
            model.VerificationStatusId = -3;

            try
            {
                long result = await Journals.VerifyTransactionAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

    }
}