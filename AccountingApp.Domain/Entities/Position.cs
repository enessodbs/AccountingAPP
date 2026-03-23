using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Position : BaseEntity<int>
{
    public int DepartmentId { get; set; }
    public string Name { get; set; } = string.Empty;
    
    public Department Department { get; set; } = null!;
    public ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
