using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    public class TrialBalanceController : FinanceDashboardController
    {
        [Route("dashboard/finance/task/trial-balance-tree")]
        [HttpPut]
        public async Task<ActionResult> TrialBalanceAsync(TrialBalanceQuery query)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(false);

            try
            {
                var data = await DAL.TrialBalanceTree.GetAsync(this.Tenant, query, meta).ConfigureAwait(true);
                return this.Ok(data);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}