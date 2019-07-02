using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [TableName("hrm.employee_qualification_scrud_view")]
    public sealed class EmployeeQualificationScrudView : IPoco
    {
        public long? EmployeeQualificationId { get; set; }
        public int? EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string EducationLevelName { get; set; }
        public string Institution { get; set; }
        public string Majors { get; set; }
        public int? TotalYears { get; set; }
        public decimal? Score { get; set; }
        public DateTimeOffset? StartedOn { get; set; }
        public DateTimeOffset? CompletedOn { get; set; }
    }
}