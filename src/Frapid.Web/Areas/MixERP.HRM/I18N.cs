using System.Collections.Generic;
using System.Globalization;
using Frapid.Configuration;
using Frapid.i18n;

namespace MixERP.HRM
{
	public sealed class Localize : ILocalize
	{
		public Dictionary<string, string> GetResources(CultureInfo culture)
		{
			string resourceDirectory = I18N.ResourceDirectory;
			return I18NResource.GetResources(resourceDirectory, culture);
		}
	}

	public static class I18N
	{
		public static string ResourceDirectory { get; }

		static I18N()
		{
			ResourceDirectory = PathMapper.MapPath("/Areas/MixERP.HRM/i18n");
		}

		/// <summary>
		///HRM
		/// </summary>
		public static string HRM => I18NResource.GetString(ResourceDirectory, "HRM");

		/// <summary>
		///Can Expire
		/// </summary>
		public static string CanExpire => I18NResource.GetString(ResourceDirectory, "CanExpire");

		/// <summary>
		///Department
		/// </summary>
		public static string Department => I18NResource.GetString(ResourceDirectory, "Department");

		/// <summary>
		///Verified By User Id
		/// </summary>
		public static string VerifiedByUserId => I18NResource.GetString(ResourceDirectory, "VerifiedByUserId");

		/// <summary>
		///Leave Type Id
		/// </summary>
		public static string LeaveTypeId => I18NResource.GetString(ResourceDirectory, "LeaveTypeId");

		/// <summary>
		///Employee
		/// </summary>
		public static string Employee => I18NResource.GetString(ResourceDirectory, "Employee");

		/// <summary>
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

		/// <summary>
		///Nationality
		/// </summary>
		public static string Nationality => I18NResource.GetString(ResourceDirectory, "Nationality");

		/// <summary>
		///Pay Grade Name
		/// </summary>
		public static string PayGradeName => I18NResource.GetString(ResourceDirectory, "PayGradeName");

		/// <summary>
		///Current Department
		/// </summary>
		public static string CurrentDepartment => I18NResource.GetString(ResourceDirectory, "CurrentDepartment");

		/// <summary>
		///Check In Time
		/// </summary>
		public static string CheckInTime => I18NResource.GetString(ResourceDirectory, "CheckInTime");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Applied On
		/// </summary>
		public static string AppliedOn => I18NResource.GetString(ResourceDirectory, "AppliedOn");

		/// <summary>
		///Bank Name
		/// </summary>
		public static string BankName => I18NResource.GetString(ResourceDirectory, "BankName");

		/// <summary>
		///Employment Status Name
		/// </summary>
		public static string EmploymentStatusName => I18NResource.GetString(ResourceDirectory, "EmploymentStatusName");

		/// <summary>
		///Education Level Id
		/// </summary>
		public static string EducationLevelId => I18NResource.GetString(ResourceDirectory, "EducationLevelId");

		/// <summary>
		///Education Level Name
		/// </summary>
		public static string EducationLevelName => I18NResource.GetString(ResourceDirectory, "EducationLevelName");

		/// <summary>
		///Leave Application Id
		/// </summary>
		public static string LeaveApplicationId => I18NResource.GetString(ResourceDirectory, "LeaveApplicationId");

		/// <summary>
		///Week Day Id
		/// </summary>
		public static string WeekDayId => I18NResource.GetString(ResourceDirectory, "WeekDayId");

		/// <summary>
		///Title
		/// </summary>
		public static string Title => I18NResource.GetString(ResourceDirectory, "Title");

		/// <summary>
		///Gender Code
		/// </summary>
		public static string GenderCode => I18NResource.GetString(ResourceDirectory, "GenderCode");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Marital Status Id
		/// </summary>
		public static string MaritalStatusId => I18NResource.GetString(ResourceDirectory, "MaritalStatusId");

		/// <summary>
		///Role Id
		/// </summary>
		public static string RoleId => I18NResource.GetString(ResourceDirectory, "RoleId");

		/// <summary>
		///Employee Type
		/// </summary>
		public static string EmployeeType => I18NResource.GetString(ResourceDirectory, "EmployeeType");

		/// <summary>
		///Social Network Name
		/// </summary>
		public static string SocialNetworkName => I18NResource.GetString(ResourceDirectory, "SocialNetworkName");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Maximum Salary
		/// </summary>
		public static string MaximumSalary => I18NResource.GetString(ResourceDirectory, "MaximumSalary");

		/// <summary>
		///Began On
		/// </summary>
		public static string BeganOn => I18NResource.GetString(ResourceDirectory, "BeganOn");

		/// <summary>
		///Phone Emergency
		/// </summary>
		public static string PhoneEmergency => I18NResource.GetString(ResourceDirectory, "PhoneEmergency");

		/// <summary>
		///Current Employment Status Id
		/// </summary>
		public static string CurrentEmploymentStatusId => I18NResource.GetString(ResourceDirectory, "CurrentEmploymentStatusId");

		/// <summary>
		///Photo
		/// </summary>
		public static string Photo => I18NResource.GetString(ResourceDirectory, "Photo");

		/// <summary>
		///Leave Benefit Code
		/// </summary>
		public static string LeaveBenefitCode => I18NResource.GetString(ResourceDirectory, "LeaveBenefitCode");

		/// <summary>
		///Resignation Id
		/// </summary>
		public static string ResignationId => I18NResource.GetString(ResourceDirectory, "ResignationId");

		/// <summary>
		///Joined On
		/// </summary>
		public static string JoinedOn => I18NResource.GetString(ResourceDirectory, "JoinedOn");

		/// <summary>
		///Hard Of Hearing
		/// </summary>
		public static string HardOfHearing => I18NResource.GetString(ResourceDirectory, "HardOfHearing");

		/// <summary>
		///Termination Id
		/// </summary>
		public static string TerminationId => I18NResource.GetString(ResourceDirectory, "TerminationId");

		/// <summary>
		///Employee Id
		/// </summary>
		public static string EmployeeId => I18NResource.GetString(ResourceDirectory, "EmployeeId");

		/// <summary>
		///Name
		/// </summary>
		public static string Name => I18NResource.GetString(ResourceDirectory, "Name");

		/// <summary>
		///State
		/// </summary>
		public static string State => I18NResource.GetString(ResourceDirectory, "State");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Exit Type Code
		/// </summary>
		public static string ExitTypeCode => I18NResource.GetString(ResourceDirectory, "ExitTypeCode");

		/// <summary>
		///Role Code
		/// </summary>
		public static string RoleCode => I18NResource.GetString(ResourceDirectory, "RoleCode");

		/// <summary>
		///Is Smoker
		/// </summary>
		public static string IsSmoker => I18NResource.GetString(ResourceDirectory, "IsSmoker");

		/// <summary>
		///Service Ended On
		/// </summary>
		public static string ServiceEndedOn => I18NResource.GetString(ResourceDirectory, "ServiceEndedOn");

		/// <summary>
		///Shift Id
		/// </summary>
		public static string ShiftId => I18NResource.GetString(ResourceDirectory, "ShiftId");

		/// <summary>
		///Job Title Name
		/// </summary>
		public static string JobTitleName => I18NResource.GetString(ResourceDirectory, "JobTitleName");

		/// <summary>
		///Started On
		/// </summary>
		public static string StartedOn => I18NResource.GetString(ResourceDirectory, "StartedOn");

		/// <summary>
		///Pay Grade Code
		/// </summary>
		public static string PayGradeCode => I18NResource.GetString(ResourceDirectory, "PayGradeCode");

		/// <summary>
		///Week Day Code
		/// </summary>
		public static string WeekDayCode => I18NResource.GetString(ResourceDirectory, "WeekDayCode");

		/// <summary>
		///Is Aphonic
		/// </summary>
		public static string IsAphonic => I18NResource.GetString(ResourceDirectory, "IsAphonic");

		/// <summary>
		///Profile Link
		/// </summary>
		public static string ProfileLink => I18NResource.GetString(ResourceDirectory, "ProfileLink");

		/// <summary>
		///With Disabilities
		/// </summary>
		public static string WithDisabilities => I18NResource.GetString(ResourceDirectory, "WithDisabilities");

		/// <summary>
		///Uses Wheelchair
		/// </summary>
		public static string UsesWheelchair => I18NResource.GetString(ResourceDirectory, "UsesWheelchair");

		/// <summary>
		///Identification Number
		/// </summary>
		public static string IdentificationNumber => I18NResource.GetString(ResourceDirectory, "IdentificationNumber");

		/// <summary>
		///Country Code
		/// </summary>
		public static string CountryCode => I18NResource.GetString(ResourceDirectory, "CountryCode");

		/// <summary>
		///Shift Name
		/// </summary>
		public static string ShiftName => I18NResource.GetString(ResourceDirectory, "ShiftName");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Service End Date
		/// </summary>
		public static string ServiceEndDate => I18NResource.GetString(ResourceDirectory, "ServiceEndDate");

		/// <summary>
		///Low Vision
		/// </summary>
		public static string LowVision => I18NResource.GetString(ResourceDirectory, "LowVision");

		/// <summary>
		///Was Absent
		/// </summary>
		public static string WasAbsent => I18NResource.GetString(ResourceDirectory, "WasAbsent");

		/// <summary>
		///Audit User Id
		/// </summary>
		public static string AuditUserId => I18NResource.GetString(ResourceDirectory, "AuditUserId");

		/// <summary>
		///Deleted
		/// </summary>
		public static string Deleted => I18NResource.GetString(ResourceDirectory, "Deleted");

		/// <summary>
		///Ends On
		/// </summary>
		public static string EndsOn => I18NResource.GetString(ResourceDirectory, "EndsOn");

		/// <summary>
		///Employee Qualification Id
		/// </summary>
		public static string EmployeeQualificationId => I18NResource.GetString(ResourceDirectory, "EmployeeQualificationId");

		/// <summary>
		///Bank Account Number
		/// </summary>
		public static string BankAccountNumber => I18NResource.GetString(ResourceDirectory, "BankAccountNumber");

		/// <summary>
		///Overtime Hours
		/// </summary>
		public static string OvertimeHours => I18NResource.GetString(ResourceDirectory, "OvertimeHours");

		/// <summary>
		///Exit Type
		/// </summary>
		public static string ExitType => I18NResource.GetString(ResourceDirectory, "ExitType");

		/// <summary>
		///Employee Type Name
		/// </summary>
		public static string EmployeeTypeName => I18NResource.GetString(ResourceDirectory, "EmployeeTypeName");

		/// <summary>
		///Notice Date
		/// </summary>
		public static string NoticeDate => I18NResource.GetString(ResourceDirectory, "NoticeDate");

		/// <summary>
		///Base Url
		/// </summary>
		public static string BaseUrl => I18NResource.GetString(ResourceDirectory, "BaseUrl");

		/// <summary>
		///Current Shift Id
		/// </summary>
		public static string CurrentShiftId => I18NResource.GetString(ResourceDirectory, "CurrentShiftId");

		/// <summary>
		///Social Network Id
		/// </summary>
		public static string SocialNetworkId => I18NResource.GetString(ResourceDirectory, "SocialNetworkId");

		/// <summary>
		///Department Name
		/// </summary>
		public static string DepartmentName => I18NResource.GetString(ResourceDirectory, "DepartmentName");

		/// <summary>
		///Date Of Birth
		/// </summary>
		public static string DateOfBirth => I18NResource.GetString(ResourceDirectory, "DateOfBirth");

		/// <summary>
		///Nationality Code
		/// </summary>
		public static string NationalityCode => I18NResource.GetString(ResourceDirectory, "NationalityCode");

		/// <summary>
		///Department Code
		/// </summary>
		public static string DepartmentCode => I18NResource.GetString(ResourceDirectory, "DepartmentCode");

		/// <summary>
		///Expires On
		/// </summary>
		public static string ExpiresOn => I18NResource.GetString(ResourceDirectory, "ExpiresOn");

		/// <summary>
		///Phone Cell
		/// </summary>
		public static string PhoneCell => I18NResource.GetString(ResourceDirectory, "PhoneCell");

		/// <summary>
		///Website
		/// </summary>
		public static string Website => I18NResource.GetString(ResourceDirectory, "Website");

		/// <summary>
		///Middle Name
		/// </summary>
		public static string MiddleName => I18NResource.GetString(ResourceDirectory, "MiddleName");

		/// <summary>
		///Identification Type Name
		/// </summary>
		public static string IdentificationTypeName => I18NResource.GetString(ResourceDirectory, "IdentificationTypeName");

		/// <summary>
		///Forward To
		/// </summary>
		public static string ForwardTo => I18NResource.GetString(ResourceDirectory, "ForwardTo");

		/// <summary>
		///Leave Benefit Name
		/// </summary>
		public static string LeaveBenefitName => I18NResource.GetString(ResourceDirectory, "LeaveBenefitName");

		/// <summary>
		///Default Employment Status Code Id
		/// </summary>
		public static string DefaultEmploymentStatusCodeId => I18NResource.GetString(ResourceDirectory, "DefaultEmploymentStatusCodeId");

		/// <summary>
		///Shift
		/// </summary>
		public static string Shift => I18NResource.GetString(ResourceDirectory, "Shift");

		/// <summary>
		///Office Hour Id
		/// </summary>
		public static string OfficeHourId => I18NResource.GetString(ResourceDirectory, "OfficeHourId");

		/// <summary>
		///Current Job Title Id
		/// </summary>
		public static string CurrentJobTitleId => I18NResource.GetString(ResourceDirectory, "CurrentJobTitleId");

		/// <summary>
		///Exit Type Name
		/// </summary>
		public static string ExitTypeName => I18NResource.GetString(ResourceDirectory, "ExitTypeName");

		/// <summary>
		///Current Pay Grade Id
		/// </summary>
		public static string CurrentPayGradeId => I18NResource.GetString(ResourceDirectory, "CurrentPayGradeId");

		/// <summary>
		///Nationality Id
		/// </summary>
		public static string NationalityId => I18NResource.GetString(ResourceDirectory, "NationalityId");

		/// <summary>
		///Identification Type Id
		/// </summary>
		public static string IdentificationTypeId => I18NResource.GetString(ResourceDirectory, "IdentificationTypeId");

		/// <summary>
		///Total Days
		/// </summary>
		public static string TotalDays => I18NResource.GetString(ResourceDirectory, "TotalDays");

		/// <summary>
		///Was Present
		/// </summary>
		public static string WasPresent => I18NResource.GetString(ResourceDirectory, "WasPresent");

		/// <summary>
		///Details
		/// </summary>
		public static string Details => I18NResource.GetString(ResourceDirectory, "Details");

		/// <summary>
		///Exit Id
		/// </summary>
		public static string ExitId => I18NResource.GetString(ResourceDirectory, "ExitId");

		/// <summary>
		///Department Id
		/// </summary>
		public static string DepartmentId => I18NResource.GetString(ResourceDirectory, "DepartmentId");

		/// <summary>
		///Country
		/// </summary>
		public static string Country => I18NResource.GetString(ResourceDirectory, "Country");

		/// <summary>
		///Employee Type Id
		/// </summary>
		public static string EmployeeTypeId => I18NResource.GetString(ResourceDirectory, "EmployeeTypeId");

		/// <summary>
		///Pay Grade
		/// </summary>
		public static string PayGrade => I18NResource.GetString(ResourceDirectory, "PayGrade");

		/// <summary>
		///Organization Name
		/// </summary>
		public static string OrganizationName => I18NResource.GetString(ResourceDirectory, "OrganizationName");

		/// <summary>
		///Icon Css Class
		/// </summary>
		public static string IconCssClass => I18NResource.GetString(ResourceDirectory, "IconCssClass");

		/// <summary>
		///Contract Id
		/// </summary>
		public static string ContractId => I18NResource.GetString(ResourceDirectory, "ContractId");

		/// <summary>
		///Last Name
		/// </summary>
		public static string LastName => I18NResource.GetString(ResourceDirectory, "LastName");

		/// <summary>
		///Street
		/// </summary>
		public static string Street => I18NResource.GetString(ResourceDirectory, "Street");

		/// <summary>
		///Change Status To
		/// </summary>
		public static string ChangeStatusTo => I18NResource.GetString(ResourceDirectory, "ChangeStatusTo");

		/// <summary>
		///Employee Type Code
		/// </summary>
		public static string EmployeeTypeCode => I18NResource.GetString(ResourceDirectory, "EmployeeTypeCode");

		/// <summary>
		///Total Years
		/// </summary>
		public static string TotalYears => I18NResource.GetString(ResourceDirectory, "TotalYears");

		/// <summary>
		///Entered By
		/// </summary>
		public static string EnteredBy => I18NResource.GetString(ResourceDirectory, "EnteredBy");

		/// <summary>
		///Nationality Name
		/// </summary>
		public static string NationalityName => I18NResource.GetString(ResourceDirectory, "NationalityName");

		/// <summary>
		///Employment Status
		/// </summary>
		public static string EmploymentStatus => I18NResource.GetString(ResourceDirectory, "EmploymentStatus");

		/// <summary>
		///Job Title Id
		/// </summary>
		public static string JobTitleId => I18NResource.GetString(ResourceDirectory, "JobTitleId");

		/// <summary>
		///Institution
		/// </summary>
		public static string Institution => I18NResource.GetString(ResourceDirectory, "Institution");

		/// <summary>
		///Audit Ts
		/// </summary>
		public static string AuditTs => I18NResource.GetString(ResourceDirectory, "AuditTs");

		/// <summary>
		///Pay Grade Id
		/// </summary>
		public static string PayGradeId => I18NResource.GetString(ResourceDirectory, "PayGradeId");

		/// <summary>
		///Current Department Id
		/// </summary>
		public static string CurrentDepartmentId => I18NResource.GetString(ResourceDirectory, "CurrentDepartmentId");

		/// <summary>
		///Completed On
		/// </summary>
		public static string CompletedOn => I18NResource.GetString(ResourceDirectory, "CompletedOn");

		/// <summary>
		///Address Line 2
		/// </summary>
		public static string AddressLine2 => I18NResource.GetString(ResourceDirectory, "AddressLine2");

		/// <summary>
		///Phone Emergency 2
		/// </summary>
		public static string PhoneEmergency2 => I18NResource.GetString(ResourceDirectory, "PhoneEmergency2");

		/// <summary>
		///Phone Office Extension
		/// </summary>
		public static string PhoneOfficeExtension => I18NResource.GetString(ResourceDirectory, "PhoneOfficeExtension");

		/// <summary>
		///Desired Resign Date
		/// </summary>
		public static string DesiredResignDate => I18NResource.GetString(ResourceDirectory, "DesiredResignDate");

		/// <summary>
		///Status Code
		/// </summary>
		public static string StatusCode => I18NResource.GetString(ResourceDirectory, "StatusCode");

		/// <summary>
		///Employment Status Id
		/// </summary>
		public static string EmploymentStatusId => I18NResource.GetString(ResourceDirectory, "EmploymentStatusId");

		/// <summary>
		///Zip Code
		/// </summary>
		public static string ZipCode => I18NResource.GetString(ResourceDirectory, "ZipCode");

		/// <summary>
		///Exit Interview Details
		/// </summary>
		public static string ExitInterviewDetails => I18NResource.GetString(ResourceDirectory, "ExitInterviewDetails");

		/// <summary>
		///Role
		/// </summary>
		public static string Role => I18NResource.GetString(ResourceDirectory, "Role");

		/// <summary>
		///Job Title Code
		/// </summary>
		public static string JobTitleCode => I18NResource.GetString(ResourceDirectory, "JobTitleCode");

		/// <summary>
		///Check Out Time
		/// </summary>
		public static string CheckOutTime => I18NResource.GetString(ResourceDirectory, "CheckOutTime");

		/// <summary>
		///Employee Code
		/// </summary>
		public static string EmployeeCode => I18NResource.GetString(ResourceDirectory, "EmployeeCode");

		/// <summary>
		///Leave Benefit Id
		/// </summary>
		public static string LeaveBenefitId => I18NResource.GetString(ResourceDirectory, "LeaveBenefitId");

		/// <summary>
		///Exit Type Id
		/// </summary>
		public static string ExitTypeId => I18NResource.GetString(ResourceDirectory, "ExitTypeId");

		/// <summary>
		///Bank Branch Name
		/// </summary>
		public static string BankBranchName => I18NResource.GetString(ResourceDirectory, "BankBranchName");

		/// <summary>
		///Role Name
		/// </summary>
		public static string RoleName => I18NResource.GetString(ResourceDirectory, "RoleName");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Address Line 1
		/// </summary>
		public static string AddressLine1 => I18NResource.GetString(ResourceDirectory, "AddressLine1");

		/// <summary>
		///Email Address
		/// </summary>
		public static string EmailAddress => I18NResource.GetString(ResourceDirectory, "EmailAddress");

		/// <summary>
		///Employment Status Code Name
		/// </summary>
		public static string EmploymentStatusCodeName => I18NResource.GetString(ResourceDirectory, "EmploymentStatusCodeName");

		/// <summary>
		///Minimum Salary
		/// </summary>
		public static string MinimumSalary => I18NResource.GetString(ResourceDirectory, "MinimumSalary");

		/// <summary>
		///Identification Type Code
		/// </summary>
		public static string IdentificationTypeCode => I18NResource.GetString(ResourceDirectory, "IdentificationTypeCode");

		/// <summary>
		///Employee Experience Id
		/// </summary>
		public static string EmployeeExperienceId => I18NResource.GetString(ResourceDirectory, "EmployeeExperienceId");

		/// <summary>
		///Leave Type Name
		/// </summary>
		public static string LeaveTypeName => I18NResource.GetString(ResourceDirectory, "LeaveTypeName");

		/// <summary>
		///Attendance Id
		/// </summary>
		public static string AttendanceId => I18NResource.GetString(ResourceDirectory, "AttendanceId");

		/// <summary>
		///Is Cognitively Disabled
		/// </summary>
		public static string IsCognitivelyDisabled => I18NResource.GetString(ResourceDirectory, "IsCognitivelyDisabled");

		/// <summary>
		///Employment Status Code
		/// </summary>
		public static string EmploymentStatusCode => I18NResource.GetString(ResourceDirectory, "EmploymentStatusCode");

		/// <summary>
		///Employee Identification Detail Id
		/// </summary>
		public static string EmployeeIdentificationDetailId => I18NResource.GetString(ResourceDirectory, "EmployeeIdentificationDetailId");

		/// <summary>
		///Score
		/// </summary>
		public static string Score => I18NResource.GetString(ResourceDirectory, "Score");

		/// <summary>
		///Blog
		/// </summary>
		public static string Blog => I18NResource.GetString(ResourceDirectory, "Blog");

		/// <summary>
		///Job Title
		/// </summary>
		public static string JobTitle => I18NResource.GetString(ResourceDirectory, "JobTitle");

		/// <summary>
		///Week Day Name
		/// </summary>
		public static string WeekDayName => I18NResource.GetString(ResourceDirectory, "WeekDayName");

		/// <summary>
		///Employee Social Network Detail Id
		/// </summary>
		public static string EmployeeSocialNetworkDetailId => I18NResource.GetString(ResourceDirectory, "EmployeeSocialNetworkDetailId");

		/// <summary>
		///Employment Status Code Id
		/// </summary>
		public static string EmploymentStatusCodeId => I18NResource.GetString(ResourceDirectory, "EmploymentStatusCodeId");

		/// <summary>
		///Is Autistic
		/// </summary>
		public static string IsAutistic => I18NResource.GetString(ResourceDirectory, "IsAutistic");

		/// <summary>
		///Marital Status
		/// </summary>
		public static string MaritalStatus => I18NResource.GetString(ResourceDirectory, "MaritalStatus");

		/// <summary>
		///Is Contract
		/// </summary>
		public static string IsContract => I18NResource.GetString(ResourceDirectory, "IsContract");

		/// <summary>
		///Status Code Name
		/// </summary>
		public static string StatusCodeName => I18NResource.GetString(ResourceDirectory, "StatusCodeName");

		/// <summary>
		///Week Day
		/// </summary>
		public static string WeekDay => I18NResource.GetString(ResourceDirectory, "WeekDay");

		/// <summary>
		///Phone Home
		/// </summary>
		public static string PhoneHome => I18NResource.GetString(ResourceDirectory, "PhoneHome");

		/// <summary>
		///Employee Name
		/// </summary>
		public static string EmployeeName => I18NResource.GetString(ResourceDirectory, "EmployeeName");

		/// <summary>
		///Status Code Id
		/// </summary>
		public static string StatusCodeId => I18NResource.GetString(ResourceDirectory, "StatusCodeId");

		/// <summary>
		///Current Role Id
		/// </summary>
		public static string CurrentRoleId => I18NResource.GetString(ResourceDirectory, "CurrentRoleId");

		/// <summary>
		///Verification Status Id
		/// </summary>
		public static string VerificationStatusId => I18NResource.GetString(ResourceDirectory, "VerificationStatusId");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Reason For Absenteeism
		/// </summary>
		public static string ReasonForAbsenteeism => I18NResource.GetString(ResourceDirectory, "ReasonForAbsenteeism");

		/// <summary>
		///Begins From
		/// </summary>
		public static string BeginsFrom => I18NResource.GetString(ResourceDirectory, "BeginsFrom");

		/// <summary>
		///Leave Type Code
		/// </summary>
		public static string LeaveTypeCode => I18NResource.GetString(ResourceDirectory, "LeaveTypeCode");

		/// <summary>
		///Bank Reference Number
		/// </summary>
		public static string BankReferenceNumber => I18NResource.GetString(ResourceDirectory, "BankReferenceNumber");

		/// <summary>
		///Attendance Date
		/// </summary>
		public static string AttendanceDate => I18NResource.GetString(ResourceDirectory, "AttendanceDate");

		/// <summary>
		///Is Alcoholic
		/// </summary>
		public static string IsAlcoholic => I18NResource.GetString(ResourceDirectory, "IsAlcoholic");

		/// <summary>
		///Gender Name
		/// </summary>
		public static string GenderName => I18NResource.GetString(ResourceDirectory, "GenderName");

		/// <summary>
		///Leave Type
		/// </summary>
		public static string LeaveType => I18NResource.GetString(ResourceDirectory, "LeaveType");

		/// <summary>
		///Ended On
		/// </summary>
		public static string EndedOn => I18NResource.GetString(ResourceDirectory, "EndedOn");

		/// <summary>
		///Majors
		/// </summary>
		public static string Majors => I18NResource.GetString(ResourceDirectory, "Majors");

		/// <summary>
		///First Name
		/// </summary>
		public static string FirstName => I18NResource.GetString(ResourceDirectory, "FirstName");

		/// <summary>
		///Start Date
		/// </summary>
		public static string StartDate => I18NResource.GetString(ResourceDirectory, "StartDate");

		/// <summary>
		///Leave Benefit
		/// </summary>
		public static string LeaveBenefit => I18NResource.GetString(ResourceDirectory, "LeaveBenefit");

		/// <summary>
		///End Date
		/// </summary>
		public static string EndDate => I18NResource.GetString(ResourceDirectory, "EndDate");

		/// <summary>
		///Shift Code
		/// </summary>
		public static string ShiftCode => I18NResource.GetString(ResourceDirectory, "ShiftCode");

		/// <summary>
		///Tasks
		/// </summary>
		public static string Tasks => I18NResource.GetString(ResourceDirectory, "Tasks");

		/// <summary>
		///Attendance
		/// </summary>
		public static string Attendance => I18NResource.GetString(ResourceDirectory, "Attendance");

		/// <summary>
		///Employees
		/// </summary>
		public static string Employees => I18NResource.GetString(ResourceDirectory, "Employees");

		/// <summary>
		///Contracts
		/// </summary>
		public static string Contracts => I18NResource.GetString(ResourceDirectory, "Contracts");

		/// <summary>
		///Leave Applications
		/// </summary>
		public static string LeaveApplications => I18NResource.GetString(ResourceDirectory, "LeaveApplications");

		/// <summary>
		///Resignations
		/// </summary>
		public static string Resignations => I18NResource.GetString(ResourceDirectory, "Resignations");

		/// <summary>
		///Terminations
		/// </summary>
		public static string Terminations => I18NResource.GetString(ResourceDirectory, "Terminations");

		/// <summary>
		///Exits
		/// </summary>
		public static string Exits => I18NResource.GetString(ResourceDirectory, "Exits");

		/// <summary>
		///Verification
		/// </summary>
		public static string Verification => I18NResource.GetString(ResourceDirectory, "Verification");

		/// <summary>
		///Verify Contracts
		/// </summary>
		public static string VerifyContracts => I18NResource.GetString(ResourceDirectory, "VerifyContracts");

		/// <summary>
		///Verify Leave Applications
		/// </summary>
		public static string VerifyLeaveApplications => I18NResource.GetString(ResourceDirectory, "VerifyLeaveApplications");

		/// <summary>
		///Verify Resignations
		/// </summary>
		public static string VerifyResignations => I18NResource.GetString(ResourceDirectory, "VerifyResignations");

		/// <summary>
		///Verify Terminations
		/// </summary>
		public static string VerifyTerminations => I18NResource.GetString(ResourceDirectory, "VerifyTerminations");

		/// <summary>
		///Verify Exits
		/// </summary>
		public static string VerifyExits => I18NResource.GetString(ResourceDirectory, "VerifyExits");

		/// <summary>
		///Setup & Configuration
		/// </summary>
		public static string SetupAndConfiguration => I18NResource.GetString(ResourceDirectory, "SetupAndConfiguration");

		/// <summary>
		///Employment Statuses
		/// </summary>
		public static string EmploymentStatuses => I18NResource.GetString(ResourceDirectory, "EmploymentStatuses");

		/// <summary>
		///Identification Types
		/// </summary>
		public static string IdentificationTypes => I18NResource.GetString(ResourceDirectory, "IdentificationTypes");

		/// <summary>
		///Employee Types
		/// </summary>
		public static string EmployeeTypes => I18NResource.GetString(ResourceDirectory, "EmployeeTypes");

		/// <summary>
		///Education Levels
		/// </summary>
		public static string EducationLevels => I18NResource.GetString(ResourceDirectory, "EducationLevels");

		/// <summary>
		///Job Titles
		/// </summary>
		public static string JobTitles => I18NResource.GetString(ResourceDirectory, "JobTitles");

		/// <summary>
		///Pay Grades
		/// </summary>
		public static string PayGrades => I18NResource.GetString(ResourceDirectory, "PayGrades");

		/// <summary>
		///Shifts
		/// </summary>
		public static string Shifts => I18NResource.GetString(ResourceDirectory, "Shifts");

		/// <summary>
		///Office Hours
		/// </summary>
		public static string OfficeHours => I18NResource.GetString(ResourceDirectory, "OfficeHours");

		/// <summary>
		///Leave Types
		/// </summary>
		public static string LeaveTypes => I18NResource.GetString(ResourceDirectory, "LeaveTypes");

		/// <summary>
		///Leave Benefits
		/// </summary>
		public static string LeaveBenefits => I18NResource.GetString(ResourceDirectory, "LeaveBenefits");

		/// <summary>
		///Exit Types
		/// </summary>
		public static string ExitTypes => I18NResource.GetString(ResourceDirectory, "ExitTypes");

		/// <summary>
		///Social Networks
		/// </summary>
		public static string SocialNetworks => I18NResource.GetString(ResourceDirectory, "SocialNetworks");

		/// <summary>
		///Nationalities
		/// </summary>
		public static string Nationalities => I18NResource.GetString(ResourceDirectory, "Nationalities");

		/// <summary>
		///Marital Statuses
		/// </summary>
		public static string MaritalStatuses => I18NResource.GetString(ResourceDirectory, "MaritalStatuses");

		/// <summary>
		///Reports
		/// </summary>
		public static string Reports => I18NResource.GetString(ResourceDirectory, "Reports");

		/// <summary>
		///Attendances
		/// </summary>
		public static string Attendances => I18NResource.GetString(ResourceDirectory, "Attendances");

		/// <summary>
		///Absenteeism Reason
		/// </summary>
		public static string AbsenteeismReason => I18NResource.GetString(ResourceDirectory, "AbsenteeismReason");

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Add New
		/// </summary>
		public static string AddNew => I18NResource.GetString(ResourceDirectory, "AddNew");

		/// <summary>
		///Address Information
		/// </summary>
		public static string AddressInformation => I18NResource.GetString(ResourceDirectory, "AddressInformation");

		/// <summary>
		///Bank Details
		/// </summary>
		public static string BankDetails => I18NResource.GetString(ResourceDirectory, "BankDetails");

		/// <summary>
		///Cell Phone
		/// </summary>
		public static string CellPhone => I18NResource.GetString(ResourceDirectory, "CellPhone");

		/// <summary>
		///Contact Information
		/// </summary>
		public static string ContactInformation => I18NResource.GetString(ResourceDirectory, "ContactInformation");

		/// <summary>
		///Contract
		/// </summary>
		public static string Contract => I18NResource.GetString(ResourceDirectory, "Contract");

		/// <summary>
		///Country Id
		/// </summary>
		public static string CountryId => I18NResource.GetString(ResourceDirectory, "CountryId");

		/// <summary>
		///Emergency Phone
		/// </summary>
		public static string EmergencyPhone => I18NResource.GetString(ResourceDirectory, "EmergencyPhone");

		/// <summary>
		///Emergency Phone 2
		/// </summary>
		public static string EmergencyPhone2 => I18NResource.GetString(ResourceDirectory, "EmergencyPhone2");

		/// <summary>
		///Employee Info
		/// </summary>
		public static string EmployeeInfo => I18NResource.GetString(ResourceDirectory, "EmployeeInfo");

		/// <summary>
		///Employment Contracts
		/// </summary>
		public static string EmploymentContracts => I18NResource.GetString(ResourceDirectory, "EmploymentContracts");
        /// <summary>
		///timesheet
		/// </summary>
		public static string Timesheet => I18NResource.GetString(ResourceDirectory, "Timesheet");

        /// <summary>
        ///Employment Information
        /// </summary>
        public static string EmploymentInformation => I18NResource.GetString(ResourceDirectory, "EmploymentInformation");

		/// <summary>
		///Experiences
		/// </summary>
		public static string Experiences => I18NResource.GetString(ResourceDirectory, "Experiences");

		/// <summary>
		///Expriences
		/// </summary>
		public static string Expriences => I18NResource.GetString(ResourceDirectory, "Expriences");

		/// <summary>
		///For Date
		/// </summary>
		public static string ForDate => I18NResource.GetString(ResourceDirectory, "ForDate");

		/// <summary>
		///Gender
		/// </summary>
		public static string Gender => I18NResource.GetString(ResourceDirectory, "Gender");

		/// <summary>
		///General Information
		/// </summary>
		public static string GeneralInformation => I18NResource.GetString(ResourceDirectory, "GeneralInformation");

		/// <summary>
		///Home Phone
		/// </summary>
		public static string HomePhone => I18NResource.GetString(ResourceDirectory, "HomePhone");

		/// <summary>
		///Identification #
		/// </summary>
		public static string Identification => I18NResource.GetString(ResourceDirectory, "Identification");

		/// <summary>
		///Identification Details
		/// </summary>
		public static string IdentificationDetails => I18NResource.GetString(ResourceDirectory, "IdentificationDetails");

		/// <summary>
		///Leave Application
		/// </summary>
		public static string LeaveApplication => I18NResource.GetString(ResourceDirectory, "LeaveApplication");

		/// <summary>
		///Other Details
		/// </summary>
		public static string OtherDetails => I18NResource.GetString(ResourceDirectory, "OtherDetails");

		/// <summary>
		///Peronsal Information
		/// </summary>
		public static string PeronsalInformation => I18NResource.GetString(ResourceDirectory, "PeronsalInformation");

		/// <summary>
		///Profile Url
		/// </summary>
		public static string ProfileUrl => I18NResource.GetString(ResourceDirectory, "ProfileUrl");

		/// <summary>
		///Qualifications
		/// </summary>
		public static string Qualifications => I18NResource.GetString(ResourceDirectory, "Qualifications");

		/// <summary>
		///Resignation
		/// </summary>
		public static string Resignation => I18NResource.GetString(ResourceDirectory, "Resignation");

		/// <summary>
		///Semantic Css Class
		/// </summary>
		public static string SemanticCssClass => I18NResource.GetString(ResourceDirectory, "SemanticCssClass");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Termination
		/// </summary>
		public static string Termination => I18NResource.GetString(ResourceDirectory, "Termination");

		/// <summary>
		///Update
		/// </summary>
		public static string Update => I18NResource.GetString(ResourceDirectory, "Update");

		/// <summary>
		///Update All
		/// </summary>
		public static string UpdateAll => I18NResource.GetString(ResourceDirectory, "UpdateAll");

		/// <summary>
		///Update Attendance Record
		/// </summary>
		public static string UpdateAttendanceRecord => I18NResource.GetString(ResourceDirectory, "UpdateAttendanceRecord");

		/// <summary>
		///UpdateEmptyCheckIns
		/// </summary>
		public static string UpdateEmptyCheckIns => I18NResource.GetString(ResourceDirectory, "UpdateEmptyCheckIns");

		/// <summary>
		///UpdateEmptyCheckOuts
		/// </summary>
		public static string UpdateEmptyCheckOuts => I18NResource.GetString(ResourceDirectory, "UpdateEmptyCheckOuts");

		/// <summary>
		///User
		/// </summary>
		public static string User => I18NResource.GetString(ResourceDirectory, "User");

		/// <summary>
		///User Name
		/// </summary>
		public static string UserName => I18NResource.GetString(ResourceDirectory, "UserName");

		/// <summary>
		///Verify Contracts
		/// </summary>
		public static string VerifyContract => I18NResource.GetString(ResourceDirectory, "VerifyContract");

		/// <summary>
		///Verify Exit
		/// </summary>
		public static string VerifyExit => I18NResource.GetString(ResourceDirectory, "VerifyExit");

		/// <summary>
		///Verify Leave Application
		/// </summary>
		public static string VerifyLeaveApplication => I18NResource.GetString(ResourceDirectory, "VerifyLeaveApplication");

		/// <summary>
		///Verify Resignation
		/// </summary>
		public static string VerifyResignation => I18NResource.GetString(ResourceDirectory, "VerifyResignation");

		/// <summary>
		///Verify Termination
		/// </summary>
		public static string VerifyTermination => I18NResource.GetString(ResourceDirectory, "VerifyTermination");

		/// <summary>
		///Yes
		/// </summary>
		public static string Yes => I18NResource.GetString(ResourceDirectory, "Yes");

	}
}
