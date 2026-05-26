using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    public class DepartmentCreateDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
    }

    public class PositionCreateDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public int DepartmentId { get; set; }
    }
}
