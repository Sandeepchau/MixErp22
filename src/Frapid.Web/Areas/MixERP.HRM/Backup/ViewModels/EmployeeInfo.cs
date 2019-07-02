using System.Collections.Generic;
using MixERP.HRM.DTO;

namespace MixERP.HRM.ViewModels
{
    public sealed class EmployeeInfo
    {
        public int EmployeeId { get; set; }
        public IEnumerable<EmployeeExperienceScrudView> Experiences { get; set; }
        public IEnumerable<EmployeeIdentificationDetailScrudView> IdentificationDetails { get; set; }
        public IEnumerable<EmployeeQualificationScrudView> Qualifications { get; set; }
        public IEnumerable<EmployeeSocialNetworkDetailScrudView> SocialNetworks { get; set; }
        public EmployeeView Details { get; set; }    
    }
}