using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MixERP.HRM.DAL.backend.task.TimesheetEntry
{
    interface ITimesheetEntry
    {
        Task<string> PostAsync(string tenant, ViewModels.Timesheet model);
    }
}
