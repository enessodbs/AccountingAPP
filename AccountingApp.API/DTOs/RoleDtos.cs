using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ======================== Rol Listeleme ========================

    /// <summary>Rol listesi için özet DTO.</summary>
    public class RoleListDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int UserCount { get; set; }
    }

    // ======================== Rol Detay ========================

    /// <summary>Tek bir rolün detay bilgisi.</summary>
    public class RoleDetailDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int UserCount { get; set; }
        public List<RoleUserDto> Users { get; set; } = new();
    }

    /// <summary>Role atanmış kullanıcının özet bilgisi.</summary>
    public class RoleUserDto
    {
        public Guid Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? FullName { get; set; }
    }

    // ======================== Rol Oluşturma ========================

    /// <summary>Yeni rol oluşturma isteği.</summary>
    public class CreateRoleDto
    {
        [Required(ErrorMessage = "Rol adı zorunludur.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Rol adı 2–50 karakter arasında olmalıdır.")]
        public string Name { get; set; } = string.Empty;

        /// <summary>Rolün açıklaması (opsiyonel).</summary>
        [StringLength(200, ErrorMessage = "Açıklama en fazla 200 karakter olabilir.")]
        public string? Description { get; set; }
    }

    // ======================== Rol Güncelleme ========================

    /// <summary>Rol bilgilerini güncelleme isteği.</summary>
    public class UpdateRoleDto
    {
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Rol adı 2–50 karakter arasında olmalıdır.")]
        public string? Name { get; set; }

        [StringLength(200, ErrorMessage = "Açıklama en fazla 200 karakter olabilir.")]
        public string? Description { get; set; }
    }
}
