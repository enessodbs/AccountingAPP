using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AccountingApp.API.Migrations
{
    /// <inheritdoc />
    public partial class AddBarcodeToProduct : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "PasswordHash",
                value: "$2a$11$kRxnQ9k9UlEDmDq4rB2lr.c55oSR2CvbsJUYphC6Av6Y9ofgVOorW");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "PasswordHash",
                value: "$2a$11$vWWV8cMaEDa0DwjmNxkJ0ekxZVqC27oOFRP93NW3.4WjYyS7P4ha2");
        }
    }
}
