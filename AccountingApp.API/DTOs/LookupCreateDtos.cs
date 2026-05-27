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

    public class CurrencyCreateDto
    {
        [Required]
        [MaxLength(3)]
        [MinLength(3)]
        public string Code { get; set; } = string.Empty;

        [MaxLength(5)]
        public string? Symbol { get; set; }
    }
}
