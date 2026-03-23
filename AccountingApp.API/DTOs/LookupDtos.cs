using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ---- Department ----
    public class DepartmentDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    // ---- Position ----
    public class PositionDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int DepartmentId { get; set; }
        public string DepartmentName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    // ---- Category ----
    public class CategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class CategoryCreateDto
    {
        [Required]
        public string Name { get; set; } = string.Empty;
    }

    // ---- Currency ----
    public class CurrencyDto
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Symbol { get; set; } = string.Empty;
    }

    // ---- BusinessContact ----
    public class BusinessContactDto
    {
        public Guid Id { get; set; }
        public byte Type { get; set; } // 1: Customer, 2: Supplier, 3: Other
        public string Name { get; set; } = string.Empty;
        public string TaxNumber { get; set; } = string.Empty;
        public string TaxOffice { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class BusinessContactCreateDto
    {
        [Required]
        public byte Type { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string TaxNumber { get; set; } = string.Empty;
        public string TaxOffice { get; set; } = string.Empty;

        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
    }
}
