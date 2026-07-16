using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BioRegisto.API.Migrations
{
    /// <inheritdoc />
    public partial class AddValidationDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "RejectionReason",
                table: "Observations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ValidatedAt",
                table: "Observations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ValidatedByUserId",
                table: "Observations",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ValidationNotes",
                table: "Observations",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RejectionReason",
                table: "Observations");

            migrationBuilder.DropColumn(
                name: "ValidatedAt",
                table: "Observations");

            migrationBuilder.DropColumn(
                name: "ValidatedByUserId",
                table: "Observations");

            migrationBuilder.DropColumn(
                name: "ValidationNotes",
                table: "Observations");
        }
    }
}
