using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Configuration.DbServer;
using Frapid.Mapper.Database;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.Update;
using MixERP.HRM.DAL.backend.task.TimesheetEntry;
using MixERP.HRM.DTO;
using MixERP.HRM.ViewModels;
using PostgreSQL = MixERP.HRM.DAL.backend.task.TimesheetEntry.PostgreSQL;
using SqlServer = MixERP.HRM.DAL.backend.task.TimesheetEntry.SqlServer;

namespace MixERP.HRM.DAL
{
    public static class TimesheetTransaction
    {
        public static async Task<string> PostAsync(string tenant, ViewModels.Timesheet model)
        {
            var entry = LocateService(tenant);

            return await entry.PostAsync(tenant, model).ConfigureAwait(false);
        }

        private static ITimesheetEntry LocateService(string tenant)
        {
            string providerName = DbProvider.GetProviderName(tenant);
            var type = DbProvider.GetDbType(providerName);

            if (type == DatabaseType.PostgreSQL)
            {
                return new PostgreSQL();
            }

            if (type == DatabaseType.SqlServer)
            {
                return new SqlServer();
            }

            throw new NotImplementedException();
        }
    }
}