using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Role : BaseEntity<int>
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    public ICollection<User> Users { get; set; } = new List<User>();
}
