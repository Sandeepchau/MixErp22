using System;
using Frapid.Backups;
using Frapid.Configuration.Models;
using Frapid.Framework.Extensions;
using Quartz;
using Quartz.Impl;

namespace Frapid.Web.Application
{
    public class BackupRegistration
    {
        public static void Register()
        {
            var parameter = Parameter.Get();

            if (string.IsNullOrWhiteSpace(parameter.BackupScheduleUTC))
            {
                return;
            }

            var factory = new StdSchedulerFactory();
            var scheduler = factory.GetScheduler();
            scheduler.Start();

            var job = JobBuilder.Create<BackupJob>().WithIdentity("Backup", "PerformBackup").Build();
            string backupScheduleUtc = parameter.BackupScheduleUTC;
            var scheduleData = backupScheduleUtc.Split(',');

            int hour = 0;
            int minute = 0;

            if (scheduleData.Length.Equals(2))
            {
                hour = scheduleData[0].To<int>();
                minute = scheduleData[1].To<int>();
            }

            var trigger = TriggerBuilder.Create().WithIdentity("Backup", "PerformBackup")
                .WithSchedule(CronScheduleBuilder.DailyAtHourAndMinute(hour, minute)
                .InTimeZone(TimeZoneInfo.Utc)).Build();

            scheduler.ScheduleJob(job, trigger);
        }
    }
}