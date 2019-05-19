using System;
using System.IO;
using Frapid.Configuration;
using Frapid.Configuration.Models;
using Serilog;
using Serilog.Core;
using Serilog.Events;

namespace Frapid.Web.Application
{
    internal static class LogManager
    {
        private static string GetLogDirectory()
        {
            string fallbackPath = PathMapper.MapPath("~/Resource/Temp");
            var parameter = Parameter.Get();
            string path = parameter.ApplicationLogDirectory;

            if (string.IsNullOrWhiteSpace(path))
            {
                return fallbackPath;
            }

            try
            {
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                return path;
            }
            catch
            {
                //It is counterproductive to log errors
                //when you know that you don't have access to the log directory
                return fallbackPath;
            }
        }

        private static string GetLogFileName()
        {
            string applicationLogDirectory = GetLogDirectory();
            string filePath = Path.Combine(applicationLogDirectory, DateTimeOffset.UtcNow.Date.ToShortDateString().Replace(@"/", "-"), "log.txt");
            return filePath;
        }

        private static LoggerConfiguration GetConfiguration()
        {
            var parameter = Parameter.Get();
            string minimumLogLevel = parameter.MinimumLogLevel;

            var levelSwitch = new LoggingLevelSwitch();

            LogEventLevel logLevel;
            Enum.TryParse(minimumLogLevel, out logLevel);

            levelSwitch.MinimumLevel = logLevel;

            return new LoggerConfiguration().MinimumLevel.ControlledBy(levelSwitch).WriteTo.RollingFile(GetLogFileName());
        }

        internal static void InternalizeLogger()
        {
            Log.Logger = GetConfiguration().CreateLogger();

            Log.Information("Application started.");
        }
    }
}