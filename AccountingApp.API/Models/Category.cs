using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public class Category : BaseEntity<int>
    {
        public string Name { get; set; } = string.Empty;

        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
