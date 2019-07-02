using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.HRM.DTO
{
    [TableName("hrm.employee_social_network_detail_scrud_view")]
    public sealed class EmployeeSocialNetworkDetailScrudView : IPoco
    {
        public long? EmployeeSocialNetworkDetailId { get; set; }
        public int? EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string SocialNetworkName { get; set; }
        public string SocialNetworkId { get; set; }
        public string SemanticCssClass { get; set; }
        public string BaseUrl { get; set; }
        public string ProfileUrl { get; set; }
    }
}