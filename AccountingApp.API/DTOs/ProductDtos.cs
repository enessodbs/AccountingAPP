using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    public class ProductDto
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public decimal UnitPrice { get; set; }
        public byte Type { get; set; } // 1: Physical, 2: Service
        public decimal StockQuantity { get; set; }

        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;

        public int CurrencyId { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public string CurrencySymbol { get; set; } = string.Empty;

        public bool IsActive { get; set; }
    }

    public class ProductCreateDto
    {
        [Required]
        public string Code { get; set; } = string.Empty;

        [Required]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }

        [Required]
        public int CategoryId { get; set; }

        [Required]
        public int CurrencyId { get; set; }

        public byte Type { get; set; } = 1; // Default: Physical

        public decimal StockQuantity { get; set; } = 0;
    }

    public class ProductUpdateDto
    {
        [Required]
        public string Code { get; set; } = string.Empty;

        [Required]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }

        [Required]
        public int CategoryId { get; set; }

        [Required]
        public int CurrencyId { get; set; }

        public byte Type { get; set; }
        public decimal StockQuantity { get; set; }
        public bool IsActive { get; set; }
    }
}
