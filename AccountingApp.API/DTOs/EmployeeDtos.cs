using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    public class EmployeeDto
    {
        public Guid Id { get; set; }
        public string IdentityNumber { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        
        public int DepartmentId { get; set; }
        public string DepartmentName { get; set; } = string.Empty; // Flattened from Department.Name

        public int PositionId { get; set; }
        public string PositionName { get; set; } = string.Empty; // Flattened from Position.Name

        public string ContactEmail { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;

        public decimal BaseSalary { get; set; }
        
        public int CurrencyId { get; set; }
        public string CurrencyCode { get; set; } = string.Empty; // Flattened from Currency.Code

        public DateTime HireDate { get; set; }
        public bool IsActive { get; set; }
    }

    public class EmployeeCreateDto
    {
        [Required]
        public string IdentityNumber { get; set; } = string.Empty;

        [Required]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        public string LastName { get; set; } = string.Empty;

        [Required]
        public int DepartmentId { get; set; }

        [Required]
        public int PositionId { get; set; }

        [EmailAddress]
        public string ContactEmail { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal BaseSalary { get; set; }

        [Required]
        public int CurrencyId { get; set; }

        public DateTime HireDate { get; set; } = DateTime.UtcNow;
    }

    public class EmployeeUpdateDto
    {
        [Required]
        public string IdentityNumber { get; set; } = string.Empty;

        [Required]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        public string LastName { get; set; } = string.Empty;

        [Required]
        public int DepartmentId { get; set; }

        [Required]
        public int PositionId { get; set; }

        [EmailAddress]
        public string ContactEmail { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal BaseSalary { get; set; }

        [Required]
        public int CurrencyId { get; set; }

        public DateTime HireDate { get; set; }
        public bool IsActive { get; set; }
    }
}
