using AccountingApp.API.Models;
using Microsoft.EntityFrameworkCore;
using System;

namespace AccountingApp.API.Data
{
    public static class ModelBuilderExtensions
    {
        public static void Seed(this ModelBuilder modelBuilder)
        {
            // 1. Seed Currencies
            var tryCurrencyId = 1;
            var usdCurrencyId = 2;
            var eurCurrencyId = 3;

            modelBuilder.Entity<Currency>().HasData(
                new Currency { Id = tryCurrencyId, Code = "TRY", Symbol = "₺", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Currency { Id = usdCurrencyId, Code = "USD", Symbol = "$", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Currency { Id = eurCurrencyId, Code = "EUR", Symbol = "€", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 3. Seed Roles (Admin, HR, Muhasebe)
            var adminRoleId = Guid.Parse("11111111-1111-1111-1111-111111111111");
            var hrRoleId = Guid.Parse("22222222-2222-2222-2222-222222222222");
            var muhasebeRoleId = Guid.Parse("33333333-3333-3333-3333-333333333300");
            var satisRoleId = Guid.Parse("44444444-4444-4444-4444-444444444400");
            var satisYoneticiRoleId = Guid.Parse("55555555-5555-5555-5555-555555555500");
            var pazarlamaRoleId = Guid.Parse("66666666-6666-6666-6666-666666666600");

            modelBuilder.Entity<Role>().HasData(
                new Role { Id = adminRoleId, Name = "Admin", NormalizedName = "ADMIN", Description = "Tam yetkili sistem yöneticisi", Permissions = "Personeller,Faturalar,Urunler,IsOrtaklari,Raporlar,KullaniciYonetimi", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = hrRoleId, Name = "İK", NormalizedName = "İK", Description = "İnsan Kaynakları departmanı kullanıcıları", Permissions = "Personeller", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = muhasebeRoleId, Name = "Muhasebe", NormalizedName = "MUHASEBE", Description = "Muhasebe ve finans departmanı kullanıcıları", Permissions = "Faturalar,Raporlar,IsOrtaklari", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = satisRoleId, Name = "Satış", NormalizedName = "SATIŞ", Description = "Satış ekibi kullanıcıları", Permissions = "Faturalar,Urunler,IsOrtaklari", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = satisYoneticiRoleId, Name = "SatışYönetici", NormalizedName = "SATIŞYÖNETICI", Description = "Satış ekibi yöneticileri", Permissions = "Faturalar,Urunler,IsOrtaklari,Raporlar", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = pazarlamaRoleId, Name = "Pazarlama", NormalizedName = "PAZARLAMA", Description = "Pazarlama departmanı kullanıcıları", Permissions = "Raporlar", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 4. Seed Admin User (default credentials — change after first login)
            var adminUserId = Guid.Parse("33333333-3333-3333-3333-333333333333");
            var adminPassword = Environment.GetEnvironmentVariable("DEFAULT_ADMIN_PASSWORD") ?? "ChangeMe123!";
            var adminPasswordHash = BCrypt.Net.BCrypt.HashPassword(adminPassword);

            modelBuilder.Entity<User>().HasData(
                new User 
                { 
                    Id = adminUserId, 
                    Username = "admin", 
                    Email = "admin@accountingapp.com", 
                    PasswordHash = adminPasswordHash,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), 
                    IsActive = true 
                }
            );

            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { UserId = adminUserId, RoleId = adminRoleId }
            );

            // 6. Seed CRM Pipeline Stages
            modelBuilder.Entity<PipelineStage>().HasData(
                new PipelineStage { Id = 1, Name = "Keşif", SortOrder = 1, DefaultProbability = 10, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 2, Name = "Teklif", SortOrder = 2, DefaultProbability = 25, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 3, Name = "Müzakere", SortOrder = 3, DefaultProbability = 50, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 4, Name = "Sözleşme", SortOrder = 4, DefaultProbability = 75, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 5, Name = "Kapatma", SortOrder = 5, DefaultProbability = 90, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );
        }
    }
}
