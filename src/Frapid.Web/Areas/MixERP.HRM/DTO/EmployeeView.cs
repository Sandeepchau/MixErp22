using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [TableName("hrm.employee_view")]
    public sealed class EmployeeView : IPoco
    {
        public int? EmployeeId { get; set; }
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string EmployeeCode { get; set; }
        public string EmployeeName { get; set; }
        public string GenderCode { get; set; }
        public string GenderName { get; set; }
        public string MaritalStatus { get; set; }
        public DateTimeOffset? JoinedOn { get; set; }
        public int? OfficeId { get; set; }
        public string Office { get; set; }
        public int? UserId { get; set; }
        public string UserName { get; set; }
        public int? EmployeeTypeId { get; set; }
        public string EmployeeType { get; set; }
        public int? CurrentDepartmentId { get; set; }
        public string CurrentDepartment { get; set; }
        public int? CurrentRoleId { get; set; }
        public string Role { get; set; }
        public int? CurrentEmploymentStatusId { get; set; }
        public string EmploymentStatus { get; set; }
        public int? CurrentJobTitleId { get; set; }
        public string JobTitle { get; set; }
        public int? CurrentPayGradeId { get; set; }
        public string PayGrade { get; set; }
        public int? CurrentShiftId { get; set; }
        public string Shift { get; set; }
        public string NationalityCode { get; set; }
        public string Nationality { get; set; }
        public DateTimeOffset? DateOfBirth { get; set; }
        public string Photo { get; set; }
        public string ZipCode { get; set; }
        public string AddressLine1 { get; set; }
        public string AddressLine2 { get; set; }
        public string Street { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public int? CountryId { get; set; }
        public string Country { get; set; }
        public string PhoneHome { get; set; }
        public string PhoneCell { get; set; }
        public string PhoneOfficeExtension { get; set; }
        public string PhoneEmergency { get; set; }
        public string PhoneEmergency2 { get; set; }
        public string EmailAddress { get; set; }
        public string Website { get; set; }
        public string Blog { get; set; }
        public bool? IsSmoker { get; set; }
        public bool? IsAlcoholic { get; set; }
        public bool? WithDisabilities { get; set; }
        public bool? LowVision { get; set; }
        public bool? UsesWheelchair { get; set; }
        public bool? HardOfHearing { get; set; }
        public bool? IsAphonic { get; set; }
        public bool? IsCognitivelyDisabled { get; set; }
        public bool? IsAutistic { get; set; }
    }
}