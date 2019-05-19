namespace Frapid.Web.Models.Helpers
{
    internal static class PasswordManager
    {
        internal static string GetHashedPassword(string userName, string plainPassword)
        {
            string salt = BCrypt.Net.BCrypt.GenerateSalt(10);
            return BCrypt.Net.BCrypt.HashPassword(userName + plainPassword, salt);
        }
    }
}
