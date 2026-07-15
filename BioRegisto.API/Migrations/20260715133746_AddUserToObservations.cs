using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BioRegisto.API.Migrations
{
    /// <inheritdoc />
    public partial class AddUserToObservations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "UserId",
                table: "Observations",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Observations_UserId",
                table: "Observations",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Observations_Users_UserId",
                table: "Observations",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Observations_Users_UserId",
                table: "Observations");

            migrationBuilder.DropIndex(
                name: "IX_Observations_UserId",
                table: "Observations");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "Observations");
        }
    }
}
