using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.Cache;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.ViewModels;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class OpeningCashController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/opening-cash")]
        [MenuPolicy]
        [AccessPolicy("sales", "opening_cash", AccessTypeEnum.Read)]
        public async Task<ActionResult> IndexAsync()
        {
            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(true);
            var dates = await Dates.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            var model = await OpeningCashTransactions.GetAsync(this.Tenant, meta.UserId, dates.Today).ConfigureAwait(true) ??
                new OpeningCash();

            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/OpeningCash/Index.cshtml", this.Tenant), model);
        }

        [Route("dashboard/sales/tasks/opening-cash")]
        [HttpPost]
        [AccessPolicy("sales", "opening_cash", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(OpeningCash model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(false);
            var dates = await Dates.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            model.UserId = meta.UserId;
            model.TransactionDate = dates.Today;

            try
            {
                await OpeningCashTransactions.AddAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}