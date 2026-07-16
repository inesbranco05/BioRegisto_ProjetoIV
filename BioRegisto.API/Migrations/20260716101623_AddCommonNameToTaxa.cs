using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BioRegisto.API.Migrations
{
    /// <inheritdoc />
    public partial class AddCommonNameToTaxa : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CommonName",
                table: "Taxa",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CommonName",
                table: "Taxa");
        }
    }
}
