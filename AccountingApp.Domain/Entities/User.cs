using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class User : AuditableEntity
{
    public int RoleId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    
    public Role Role { get; set; } = null!;
}
