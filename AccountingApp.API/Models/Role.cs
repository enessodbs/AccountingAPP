using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public class Role : BaseEntity<Guid>
    {
        public string Name { get; set; } = string.Empty;

        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
