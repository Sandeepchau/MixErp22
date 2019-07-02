using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas;
using Frapid.Dashboard;
using Frapid.Dashboard.Controllers;
using Frapid.DataAccess.Models;
using MixERP.HRM.DAL;
using MixERP.HRM.ViewModels;

namespace MixERP.HRM.Controllers.Tasks
{
    public class TimesheetController : DashboardController
    {
        [Route("dashboard/hrm/tasks/Timesheet")]
        [MenuPolicy]
        [ScrudFactory]
        [AccessPolicy("hrm", "timesheet", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Timesheet/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/hrm/tasks/Timesheet")]
        [HttpPost]
        [AccessPolicy("hrm", "timesheet", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(Timesheet model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync(this.Tenant).ConfigureAwait(false);
           // var dates = await Dates.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);


            model.UserId = meta.UserId;


            try
            {
                await TimesheetTransaction.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

    }
}
