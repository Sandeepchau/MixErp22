﻿using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;
using Frapid.WebApi;
using MixERP.HRM.DAL;

namespace MixERP.HRM.Controllers.Verifications
{
    [AntiForgery]
    public class ExitVerificationController : DashboardController
    {
        [Route("dashboard/hrm/verification/exits")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "exits", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Verification/Exits/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/hrm/verification/exits")]
        [MenuPolicy]
        [ScrudFactory]
        [HttpPut]
        [AccessPolicy("hrm", "exits", AccessTypeEnum.Verify)]
        public async Task<ActionResult> VerifyAsync(Verification model)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                await Exits.VerifyAsync(this.Tenant, meta.LoginId, meta.UserId, model).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}