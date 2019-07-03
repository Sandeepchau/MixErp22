using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.Cache;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.DTO;
using MixERP.Sales.ViewModels;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class ClosingCashController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/eod")]
        [MenuPolicy]
        [AccessPolicy("sales", "sales_view", AccessTypeEnum.Read)]
        public async Task<ActionResult> IndexAsync()
        {
            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(true);
            var dates = await Dates.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            var openingCash = await OpeningCashTransactions.GetAsync(this.Tenant, meta.UserId, dates.Today).ConfigureAwait(true);

            var closingCash = await ClosingCashTransactions.GetAsync(this.Tenant, meta.UserId, dates.Today).ConfigureAwait(true);

            var salesView = await ClosingCashTransactions.GetCashSalesViewAsync(this.Tenant, meta.UserId, dates.Today).ConfigureAwait(true);


            var model = new ClosingCashViewModel
            {
                OpeningCashInfo = openingCash ?? new OpeningCash { TransactionDate = dates.Today },
                SalesView = salesView ?? new List<SalesView>(),
                ClosingCashInfo = closingCash ?? new ClosingCash { TransactionDate = dates.Today }
            };

            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/ClosingCash/Index.cshtml", this.Tenant), model);
        }

        [Route("dashboard/sales/tasks/eod")]
        [HttpPost]
        [MenuPolicy]
        [AccessPolicy("sales", "closing_cash", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(ClosingCash model)
        {
            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(true);
            var dates = await Dates.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            model.UserId = meta.UserId;
            model.TransactionDate = dates.Today;
            model.AuditUserId = meta.UserId;
            model.AuditTs = DateTimeOffset.UtcNow;
            model.Deleted = false;

            await ClosingCashTransactions.AddAsync(this.Tenant, model).ConfigureAwait(true);
            return this.Ok();
        }
    }
}