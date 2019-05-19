using System;
using Frapid.Configuration;
using Frapid.Configuration.Models;
using Frapid.Framework.Extensions;
using Frapid.Web.Jobs;
using Quartz;
using Quartz.Impl;

namespace Frapid.Web.Application
{
    public class EodTaskRegistration
    {
        public static void Register()
        {
            var parameter = Parameter.Get();

            if (string.IsNullOrWhiteSpace(parameter.EodScheduleUTC))
            {
                return;
            }

            var factory = new StdSchedulerFactory();
            var scheduler = factory.GetScheduler();
            scheduler.Start();

            string backupScheduleUtc = parameter.EodScheduleUTC;
            var scheduleData = backupScheduleUtc.Split(',');

            int hour = 0;
            int minute = 0;

            if (scheduleData.Length.Equals(2))
            {
                hour = scheduleData[0].To<int>();
                minute = scheduleData[1].To<int>();
            }

            var job = JobBuilder.Create<EndOfDayJob>().WithIdentity("DayEndTask", "Reminders").Build();
            var trigger = TriggerBuilder.Create().WithIdentity("DayEndTask", "Reminders").WithSchedule(CronScheduleBuilder.DailyAtHourAndMinute(hour, minute).InTimeZone(TimeZoneInfo.Utc)).Build();

            scheduler.ScheduleJob(job, trigger);
        }
    }
}