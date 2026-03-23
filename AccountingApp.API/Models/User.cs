using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public class User : BaseEntity<Guid>
    {
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;

        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
