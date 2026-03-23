using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AccountingApp.API.Data.Migrations
{
    /// <inheritdoc />
    public partial class SeedRoleBasedUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "PasswordHash",
                value: "$2a$11$KRgmOZnzik60YFSXjGFQUOwX..JkTIy/CCwthfQallEqe2NeAn4Ba");

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "Email", "IsActive", "PasswordHash", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { new Guid("66666666-6666-6666-6666-666666666666"), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "ik@accountingapp.com", true, "$2a$11$PkgV9kIogSQpwCoAPr9fdeUA1Eud/4wcl7lla950nOzFbsaKMaJcq", null, "ik_user" },
                    { new Guid("77777777-7777-7777-7777-777777777777"), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "muhasebe@accountingapp.com", true, "$2a$11$arnYbU12KoAKOkxFgFpsQ.1eWQvCmXmZh0B4b0Zk/vZfjhfKVGW1C", null, "muhasebe_user" }
                });

            migrationBuilder.InsertData(
                table: "Employees",
                columns: new[] { "Id", "BaseSalary", "ContactEmail", "CreatedAt", "CurrencyId", "DepartmentId", "FirstName", "HireDate", "IdentityNumber", "IsActive", "LastName", "Phone", "PositionId", "UpdatedAt", "UserId" },
                values: new object[,]
                {
                    { new Guid("66660000-6666-6666-6666-666666666666"), 32000.00m, "fatma.demir@test.com", new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 2, "Fatma", new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Utc), "11122233344", true, "Demir", "5553334455", 2, null, new Guid("66666666-6666-6666-6666-666666666666") },
                    { new Guid("77770000-7777-7777-7777-777777777777"), 38000.00m, "mehmet.ozturk@test.com", new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, 3, "Mehmet", new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "55566677788", true, "Öztürk", "5556667788", 3, null, new Guid("77777777-7777-7777-7777-777777777777") }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[,]
                {
                    { new Guid("22222222-2222-2222-2222-222222222222"), new Guid("66666666-6666-6666-6666-666666666666") },
                    { new Guid("33333333-3333-3333-3333-333333333300"), new Guid("77777777-7777-7777-7777-777777777777") }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "Id",
                keyValue: new Guid("66660000-6666-6666-6666-666666666666"));

            migrationBuilder.DeleteData(
                table: "Employees",
                keyColumn: "Id",
                keyValue: new Guid("77770000-7777-7777-7777-777777777777"));

            migrationBuilder.DeleteData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { new Guid("22222222-2222-2222-2222-222222222222"), new Guid("66666666-6666-6666-6666-666666666666") });

            migrationBuilder.DeleteData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { new Guid("33333333-3333-3333-3333-333333333300"), new Guid("77777777-7777-7777-7777-777777777777") });

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "PasswordHash",
                value: "$2a$11$l1RLd1JRsq3NNlrDcMKjQ.6eM9WFVrTGaccEAfBn5kmaWyEed8bIK");
        }
    }
}
