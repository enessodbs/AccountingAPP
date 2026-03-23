using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public class Position : BaseEntity<int>
    {
        public string Name { get; set; } = string.Empty;

        public int DepartmentId { get; set; }
        public Department Department { get; set; } = null!;

        public ICollection<Employee> Employees { get; set; } = new List<Employee>();
    }
}
