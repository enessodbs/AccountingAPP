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

            // 2. Seed Departments & Positions
            var itDeptId = 1;
            var hrDeptId = 2;
            var accDeptId = 3;

            modelBuilder.Entity<Department>().HasData(
                new Department { Id = itDeptId, Name = "Bilgi İşlem (IT)", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Department { Id = hrDeptId, Name = "İnsan Kaynakları", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Department { Id = accDeptId, Name = "Muhasebe & Finans", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            var devPosId = 1;
            var hrSpecPosId = 2;
            var accManPosId = 3;

            modelBuilder.Entity<Position>().HasData(
                new Position { Id = devPosId, DepartmentId = itDeptId, Name = "Yazılım Geliştirici", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Position { Id = hrSpecPosId, DepartmentId = hrDeptId, Name = "İK Uzmanı", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Position { Id = accManPosId, DepartmentId = accDeptId, Name = "Finans Müdürü", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 3. Seed Roles (Admin, HR, Muhasebe)
            var adminRoleId = Guid.Parse("11111111-1111-1111-1111-111111111111");
            var hrRoleId = Guid.Parse("22222222-2222-2222-2222-222222222222");
            var muhasebeRoleId = Guid.Parse("33333333-3333-3333-3333-333333333300");
            var satisRoleId = Guid.Parse("44444444-4444-4444-4444-444444444400");
            var satisYoneticiRoleId = Guid.Parse("55555555-5555-5555-5555-555555555500");
            var pazarlamaRoleId = Guid.Parse("66666666-6666-6666-6666-666666666600");

            modelBuilder.Entity<Role>().HasData(
                new Role { Id = adminRoleId, Name = "Admin", NormalizedName = "ADMIN", Description = "Tam yetkili sistem yöneticisi", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = hrRoleId, Name = "İK", NormalizedName = "İK", Description = "İnsan Kaynakları departmanı kullanıcıları", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = muhasebeRoleId, Name = "Muhasebe", NormalizedName = "MUHASEBE", Description = "Muhasebe ve finans departmanı kullanıcıları", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = satisRoleId, Name = "Satış", NormalizedName = "SATIŞ", Description = "Satış ekibi kullanıcıları", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = satisYoneticiRoleId, Name = "SatışYönetici", NormalizedName = "SATIŞYÖNETICI", Description = "Satış ekibi yöneticileri", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Role { Id = pazarlamaRoleId, Name = "Pazarlama", NormalizedName = "PAZARLAMA", Description = "Pazarlama departmanı kullanıcıları", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 4. Seed Admin User (default credentials — change after first login)
            var adminUserId = Guid.Parse("33333333-3333-3333-3333-333333333333");
            var adminPasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!");

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

            // 5. Seed Categories
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Yazılım Hizmetleri", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Category { Id = 2, Name = "Donanım", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Category { Id = 3, Name = "Ofis Malzemeleri", CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 6. Seed BusinessContacts
            var customer1Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
            var supplier1Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");

            modelBuilder.Entity<BusinessContact>().HasData(
                new BusinessContact
                {
                    Id = customer1Id,
                    Type = ContactType.Customer,
                    Name = "ABC Yazılım Danışmanlık A.Ş.",
                    TaxNumber = "1234567890",
                    TaxOffice = "Ankara VD",
                    Email = "info@abcyazilim.com",
                    Phone = "3121234567",
                    Address = "Ankara Çankaya",
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new BusinessContact
                {
                    Id = supplier1Id,
                    Type = ContactType.Supplier,
                    Name = "XYZ Teknoloji Tedarik Ltd.",
                    TaxNumber = "0987654321",
                    TaxOffice = "İstanbul VD",
                    Email = "satis@xyztech.com",
                    Phone = "2129876543",
                    Address = "İstanbul Kadıköy",
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 7. Seed Products
            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    CategoryId = 1,
                    Code = "SRV-001",
                    Name = "Web Geliştirme Hizmeti",
                    Description = "Kurumsal web sitesi geliştirme",
                    SerialNumber = "",
                    UnitPrice = 15000.00m,
                    CurrencyId = tryCurrencyId,
                    Type = ProductType.Service,
                    StockQuantity = 0,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new Product
                {
                    Id = 2,
                    CategoryId = 2,
                    Code = "HW-001",
                    Name = "Dizüstü Bilgisayar",
                    Description = "Kurumsal kullanım dizüstü bilgisayar",
                    SerialNumber = "SN-2025-HW001",
                    UnitPrice = 45000.00m,
                    CurrencyId = tryCurrencyId,
                    Type = ProductType.Physical,
                    StockQuantity = 10,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new Product
                {
                    Id = 3,
                    CategoryId = 3,
                    Code = "OFC-001",
                    Name = "Kırtasiye Paketi",
                    Description = "Aylık kırtasiye malzemeleri",
                    SerialNumber = "",
                    UnitPrice = 500.00m,
                    CurrencyId = tryCurrencyId,
                    Type = ProductType.Physical,
                    StockQuantity = 50,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 8. Seed Test Employees
            modelBuilder.Entity<Employee>().HasData(
                new Employee
                {
                    Id = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                    UserId = adminUserId,
                    IdentityNumber = "12345678901",
                    FirstName = "Ahmet",
                    LastName = "Yılmaz",
                    DepartmentId = itDeptId,
                    PositionId = devPosId,
                    ContactEmail = "ahmet.yilmaz@test.com",
                    Phone = "5551234567",
                    BaseSalary = 45000.00m,
                    CurrencyId = tryCurrencyId,
                    HireDate = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new Employee
                {
                    Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                    IdentityNumber = "10987654321",
                    FirstName = "Ayşe",
                    LastName = "Kaya",
                    DepartmentId = hrDeptId,
                    PositionId = hrSpecPosId,
                    ContactEmail = "ayse.kaya@test.com",
                    Phone = "5559876543",
                    BaseSalary = 35000.00m,
                    CurrencyId = tryCurrencyId,
                    HireDate = new DateTime(2024, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 8b. Seed İK User
            var ikUserId = Guid.Parse("66666666-6666-6666-6666-666666666666");
            var ikPasswordHash = BCrypt.Net.BCrypt.HashPassword("Ik123!");

            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = ikUserId,
                    Username = "ik_user",
                    Email = "ik@accountingapp.com",
                    PasswordHash = ikPasswordHash,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { UserId = ikUserId, RoleId = hrRoleId }
            );

            modelBuilder.Entity<Employee>().HasData(
                new Employee
                {
                    Id = Guid.Parse("66660000-6666-6666-6666-666666666666"),
                    UserId = ikUserId,
                    IdentityNumber = "11122233344",
                    FirstName = "Fatma",
                    LastName = "Demir",
                    DepartmentId = hrDeptId,
                    PositionId = hrSpecPosId,
                    ContactEmail = "fatma.demir@test.com",
                    Phone = "5553334455",
                    BaseSalary = 32000.00m,
                    CurrencyId = tryCurrencyId,
                    HireDate = new DateTime(2024, 6, 1, 0, 0, 0, DateTimeKind.Utc),
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 8c. Seed Muhasebe User
            var muhasebeUserId = Guid.Parse("77777777-7777-7777-7777-777777777777");
            var muhasebePasswordHash = BCrypt.Net.BCrypt.HashPassword("Muhasebe123!");

            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = muhasebeUserId,
                    Username = "muhasebe_user",
                    Email = "muhasebe@accountingapp.com",
                    PasswordHash = muhasebePasswordHash,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { UserId = muhasebeUserId, RoleId = muhasebeRoleId }
            );

            modelBuilder.Entity<Employee>().HasData(
                new Employee
                {
                    Id = Guid.Parse("77770000-7777-7777-7777-777777777777"),
                    UserId = muhasebeUserId,
                    IdentityNumber = "55566677788",
                    FirstName = "Mehmet",
                    LastName = "Öztürk",
                    DepartmentId = accDeptId,
                    PositionId = accManPosId,
                    ContactEmail = "mehmet.ozturk@test.com",
                    Phone = "5556667788",
                    BaseSalary = 38000.00m,
                    CurrencyId = tryCurrencyId,
                    HireDate = new DateTime(2024, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 9. Seed Sample Invoices
            var inv1Id = Guid.Parse("ff000000-0000-0000-0000-000000000001");
            var inv2Id = Guid.Parse("ff000000-0000-0000-0000-000000000002");

            modelBuilder.Entity<Invoice>().HasData(
                new Invoice
                {
                    Id = inv1Id,
                    InvoiceNumber = "INV-202603-0001",
                    BusinessContactId = customer1Id,
                    Type = InvoiceType.Sales,
                    Status = InvoiceStatus.Pending,
                    IssueDate = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                    DueDate = new DateTime(2026, 3, 15, 0, 0, 0, DateTimeKind.Utc),
                    TotalAmount = 53100.00m,
                    TaxAmount = 8100.00m,
                    CurrencyId = tryCurrencyId,
                    ExchangeRate = 1.0m,
                    CreatedById = adminUserId,
                    PaymentTerms = "15 gün içinde ödeme",
                    WaybillNumber = "",
                    CreatedAt = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new Invoice
                {
                    Id = inv2Id,
                    InvoiceNumber = "INV-202603-0002",
                    BusinessContactId = supplier1Id,
                    Type = InvoiceType.Purchase,
                    Status = InvoiceStatus.Paid,
                    IssueDate = new DateTime(2026, 2, 20, 0, 0, 0, DateTimeKind.Utc),
                    DueDate = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc),
                    TotalAmount = 590.00m,
                    TaxAmount = 90.00m,
                    CurrencyId = tryCurrencyId,
                    ExchangeRate = 1.0m,
                    CreatedById = adminUserId,
                    PaymentTerms = "Peşin",
                    WaybillNumber = "İRS-2026-001",
                    CreatedAt = new DateTime(2026, 2, 20, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            // 10. Seed Invoice Lines
            modelBuilder.Entity<InvoiceLine>().HasData(
                new InvoiceLine
                {
                    Id = Guid.Parse("ff100000-0000-0000-0000-000000000001"),
                    InvoiceId = inv1Id,
                    ProductId = 1,
                    Quantity = 3,
                    UnitPrice = 15000.00m,
                    TaxRate = 18.00m,
                    LineTotal = 53100.00m,
                    CreatedAt = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                },
                new InvoiceLine
                {
                    Id = Guid.Parse("ff100000-0000-0000-0000-000000000002"),
                    InvoiceId = inv2Id,
                    ProductId = 3,
                    Quantity = 1,
                    UnitPrice = 500.00m,
                    TaxRate = 18.00m,
                    LineTotal = 590.00m,
                    CreatedAt = new DateTime(2026, 2, 20, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );
            // 11. Seed CRM Pipeline Stages
            modelBuilder.Entity<PipelineStage>().HasData(
                new PipelineStage { Id = 1, Name = "Keşif", SortOrder = 1, DefaultProbability = 10, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 2, Name = "Teklif", SortOrder = 2, DefaultProbability = 25, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 3, Name = "Müzakere", SortOrder = 3, DefaultProbability = 50, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 4, Name = "Sözleşme", SortOrder = 4, DefaultProbability = 75, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new PipelineStage { Id = 5, Name = "Kapatma", SortOrder = 5, DefaultProbability = 90, CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );

            // 12. Seed Satış User
            var satisUserId = Guid.Parse("88888888-8888-8888-8888-888888888888");
            var satisPasswordHash = BCrypt.Net.BCrypt.HashPassword("Satis123!");

            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = satisUserId,
                    Username = "satis_user",
                    Email = "satis@accountingapp.com",
                    PasswordHash = satisPasswordHash,
                    CreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    IsActive = true
                }
            );

            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { UserId = satisUserId, RoleId = satisRoleId }
            );
        }
    }
}
