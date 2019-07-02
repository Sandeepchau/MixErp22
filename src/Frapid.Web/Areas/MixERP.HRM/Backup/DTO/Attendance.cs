using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [PrimaryKey("attendance_id", AutoIncrement = true)]
    [TableName("hrm.attendances")]
    public sealed class Attendance : IPoco
    {
        public long AttendanceId { get; set; }
        public int OfficeId { get; set; }
        public int EmployeeId { get; set; }
        public DateTime AttendanceDate { get; set; }
        public bool WasPresent { get; set; }
        public TimeSpan CheckInTime { get; set; }
        public TimeSpan CheckOutTime { get; set; }
        public decimal OvertimeHours { get; set; }
        public bool WasAbsent { get; set; }
        public string ReasonForAbsenteeism { get; set; }
        public int? AuditUserId { get; set; }
        public DateTime? AuditTs { get; set; }
    }
}