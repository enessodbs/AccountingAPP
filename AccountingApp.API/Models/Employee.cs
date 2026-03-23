using System;

namespace AccountingApp.API.Models
{
    public class Employee : BaseEntity<Guid>
    {
        public Guid? UserId { get; set; }
        public User User { get; set; } = null!;

        public string IdentityNumber { get; set; } = string.Empty; // TC Kimlik vb.
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;

        public int DepartmentId { get; set; }
        public Department Department { get; set; } = null!;

        public int PositionId { get; set; }
        public Position Position { get; set; } = null!;

        public string ContactEmail { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;

        public decimal BaseSalary { get; set; }
        
        public int CurrencyId { get; set; }
        public Currency Currency { get; set; } = null!;

        public DateTime HireDate { get; set; }
    }
}
