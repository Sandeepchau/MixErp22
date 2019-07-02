using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [TableName("hrm.employee_identification_detail_scrud_view")]
    public sealed class EmployeeIdentificationDetailScrudView : IPoco
    {
        public long? EmployeeIdentificationDetailId { get; set; }
        public int? EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string IdentificationTypeCode { get; set; }
        public string IdentificationTypeName { get; set; }
        public string IdentificationNumber { get; set; }
        public DateTime? ExpiresOn { get; set; }
    }
}