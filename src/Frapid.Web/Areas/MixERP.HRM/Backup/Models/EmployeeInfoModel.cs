using System;
using System.Threading.Tasks;
using Frapid.ApplicationState.CacheFactory;
using MixERP.HRM.DAL;
using MixERP.HRM.ViewModels;

namespace MixERP.HRM.Models
{
    public static class EmployeeInfoModel
    {
        public static async Task<EmployeeInfo> GetAsync(string tenant, int employeeId)
        {
            string key = tenant + ".employeeinfo." + employeeId;
            var factory = new DefaultCacheFactory();
            var model = factory.Get<EmployeeInfo>(key);

            if (model == null)
            {
                model = await FromStoreAsync(tenant, employeeId).ConfigureAwait(false);
                factory.Add(key, model, DateTimeOffset.UtcNow.AddMinutes(2));
            }

            return model;
        }

        public static async Task<EmployeeInfo> FromStoreAsync(string tenant, int employeeId)
        {
            var details =
                await Employees.GetEmployeeAsync(tenant, employeeId).ConfigureAwait(false);

            var experiences =
                await EmployeeExperiences.GetEmployeeExperiencesAsync(tenant, employeeId).ConfigureAwait(false);


            var identifications = await
                EmployeeIdentificationDetails.GetEmployeeIdentificationsAsync(tenant, employeeId).ConfigureAwait(false);

            var qualifications =
                await EmployeeQualifications.GetQualificationsAsync(tenant, employeeId).ConfigureAwait(false);

            var socialNetworks =
                await EmployeeSocialNetworks.GetSocialNetworksAsync(tenant, employeeId).ConfigureAwait(false);

            return new EmployeeInfo
            {
                EmployeeId = employeeId,
                Details = details,
                Experiences = experiences,
                IdentificationDetails = identifications,
                Qualifications = qualifications,
                SocialNetworks = socialNetworks
            };
        }
    }
}