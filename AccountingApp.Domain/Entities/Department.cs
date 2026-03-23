using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Department : BaseEntity<int>
{
    public string Name { get; set; } = string.Empty;
    
    public ICollection<Position> Positions { get; set; } = new List<Position>();
    public ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
