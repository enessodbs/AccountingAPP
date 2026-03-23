using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    // 1: Physical (Stock Tracking), 2: Service (No Stock Tracking)
    public enum ProductType : byte
    {
        Physical = 1,
        Service = 2
    }

    public class Product : BaseEntity<int>
    {
        public int CategoryId { get; set; }
        public Category Category { get; set; } = null!;

        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty; // Seri No
        public string Barcode { get; set; } = string.Empty;

        public decimal UnitPrice { get; set; }
        
        public int CurrencyId { get; set; }
        public Currency Currency { get; set; } = null!;

        public ProductType Type { get; set; }
        
        public decimal StockQuantity { get; set; } // Can be 0 for services

        public ICollection<StockMovement> StockMovements { get; set; } = new List<StockMovement>();
    }
}
