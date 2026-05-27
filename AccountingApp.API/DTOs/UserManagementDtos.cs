using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ======================== Kullanıcı Listeleme ========================

    /// <summary>Kullanıcı listesi için özet DTO.</summary>
    public class UserListDto
    {
        public Guid Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? FullName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public List<RoleSummaryDto> Roles { get; set; } = new();
    }

    /// <summary>Rol özet bilgisi (Id + Name).</summary>
    public class RoleSummaryDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    // ======================== Kullanıcı Detay ========================

    /// <summary>Tek bir kullanıcının detay bilgisi.</summary>
    public class UserDetailDto
    {
        public Guid Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? FullName { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public List<RoleSummaryDto> Roles { get; set; } = new();
    }

    // ======================== Kullanıcı Oluşturma ========================

    /// <summary>Yeni kullanıcı oluşturma isteği.</summary>
    public class CreateUserDto
    {
        [Required(ErrorMessage = "Kullanıcı adı zorunludur.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Kullanıcı adı 3–50 karakter arasında olmalıdır.")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "E-posta adresi zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Şifre zorunludur.")]
        [MinLength(6, ErrorMessage = "Şifre en az 6 karakter olmalıdır.")]
        public string Password { get; set; } = string.Empty;

        /// <summary>Opsiyonel — kullanıcının tam adı.</summary>
        public string? FullName { get; set; }

        /// <summary>Atanacak rol adları listesi. Boşsa varsayılan "Muhasebe" atanır.</summary>
        public List<string> RoleNames { get; set; } = new();
    }

    // ======================== Kullanıcı Güncelleme ========================

    /// <summary>Kullanıcı bilgilerini güncelleme isteği.</summary>
    public class UpdateUserDto
    {
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Kullanıcı adı 3–50 karakter arasında olmalıdır.")]
        public string? Username { get; set; }

        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        public string? Email { get; set; }

        public string? FullName { get; set; }
    }

    // ======================== Rol Atama ========================

    /// <summary>Kullanıcıya rol atama/güncelleme isteği.</summary>
    public class UpdateUserRolesDto
    {
        [Required(ErrorMessage = "En az bir rol belirtilmelidir.")]
        [MinLength(1, ErrorMessage = "En az bir rol belirtilmelidir.")]
        public List<string> RoleNames { get; set; } = new();
    }

    // ======================== Şifre Sıfırlama ========================

    /// <summary>Admin tarafından şifre sıfırlama isteği.</summary>
    public class ResetPasswordDto
    {
        [Required(ErrorMessage = "Yeni şifre zorunludur.")]
        [MinLength(6, ErrorMessage = "Şifre en az 6 karakter olmalıdır.")]
        public string NewPassword { get; set; } = string.Empty;
    }

    // ======================== Auth İstekleri ========================

    /// <summary>Giriş isteği.</summary>
    public class LoginRequestDto
    {
        [Required(ErrorMessage = "Kullanıcı adı zorunludur.")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Şifre zorunludur.")]
        public string Password { get; set; } = string.Empty;
    }

    /// <summary>Şifremi unuttum isteği.</summary>
    public class ForgotPasswordRequestDto
    {
        [Required(ErrorMessage = "E-posta adresi zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        public string Email { get; set; } = string.Empty;
    }

    /// <summary>Giriş yanıtı (JWT token ile).</summary>
    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? FullName { get; set; }
        public List<string> Roles { get; set; } = new();
        public List<string> Permissions { get; set; } = new();
    }
}
