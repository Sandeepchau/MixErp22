using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.ViewModels;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    [AntiForgery]
    public class GiftCardFundVerificationController : SalesDashboardController
    {
        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "gift_cards", AccessTypeEnum.Verify)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/AddFund/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/verification/approve")]
        [HttpPost]
        [AccessPolicy("finance", "transactions", AccessTypeEnum.Verify)]
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

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/verification/reject")]
        [HttpPost]
        [AccessPolicy("finance", "transactions", AccessTypeEnum.Verify)]
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