using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [TableName("hrm.employee_experience_scrud_view")]
    public sealed class EmployeeExperienceScrudView : IPoco
    {
        public long? EmployeeExperienceId { get; set; }
        public int? EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string OrganizationName { get; set; }
        public string Title { get; set; }
        public DateTimeOffset? StartedOn { get; set; }
        public DateTimeOffset? EndedOn { get; set; }
    }
}