using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.Update;
using MixERP.HRM.DTO;

namespace MixERP.HRM.DAL
{
    public static class Attendances
    {
        public static async Task PostAsync(string tenant, List<Attendance> model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                await db.BeginTransactionAsync().ConfigureAwait(false);

                try
                {
                    foreach (var attendance in model)
                    {
                        if (attendance.AttendanceId > 0)
                        {
                            await db.UpdateAsync(attendance, attendance.AttendanceId).ConfigureAwait(false);
                        }
                        else
                        {
                            await db.InsertAsync(attendance).ConfigureAwait(false);
                        }
                    }

                    db.CommitTransaction();
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
    }
}