using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Employee : AuditableEntity
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public int DepartmentId { get; set; }
    public int PositionId { get; set; }
    public decimal Salary { get; set; }
    public DateTime HireDate { get; set; }
    public int? CurrencyId { get; set; }
    
    public Department Department { get; set; } = null!;
    public Position Position { get; set; } = null!;
    public Currency? Currency { get; set; }
}
