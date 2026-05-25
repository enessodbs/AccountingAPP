using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    /// <summary>
    /// Sistemdeki kullanıcıyı temsil eder.  
    /// Bir kullanıcının birden fazla rolü olabilir (çoka-çok ilişki UserRole üzerinden).
    /// </summary>
    public class User : BaseEntity<Guid>
    {
        /// <summary>Benzersiz kullanıcı adı.</summary>
        public string Username { get; set; } = string.Empty;

        /// <summary>Benzersiz e-posta adresi.</summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>BCrypt ile hashlenmiş şifre.</summary>
        public string PasswordHash { get; set; } = string.Empty;

        /// <summary>Kullanıcının tam adı (opsiyonel, admin paneli görüntülemesi için).</summary>
        public string? FullName { get; set; }

        /// <summary>Son başarılı giriş tarihi (güvenlik takibi).</summary>
        public DateTime? LastLoginAt { get; set; }

        /// <summary>Refresh token değeri (ileride token yenileme akışı için).</summary>
        public string? RefreshToken { get; set; }

        /// <summary>Refresh token'ın son geçerlilik tarihi.</summary>
        public DateTime? RefreshTokenExpiryTime { get; set; }

        /// <summary>Kullanıcıya atanmış roller (çoka-çok ilişki).</summary>
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
