using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace BioRegisto.API.Migrations
{
    /// <inheritdoc />
    public partial class AddTaxonomy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TaxonId",
                table: "Observations",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Taxa",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Rank = table.Column<string>(type: "text", nullable: false),
                    ParentId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Taxa", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Taxa_Taxa_ParentId",
                        column: x => x.ParentId,
                        principalTable: "Taxa",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Observations_TaxonId",
                table: "Observations",
                column: "TaxonId");

            migrationBuilder.CreateIndex(
                name: "IX_Taxa_ParentId",
                table: "Taxa",
                column: "ParentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Observations_Taxa_TaxonId",
                table: "Observations",
                column: "TaxonId",
                principalTable: "Taxa",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Observations_Taxa_TaxonId",
                table: "Observations");

            migrationBuilder.DropTable(
                name: "Taxa");

            migrationBuilder.DropIndex(
                name: "IX_Observations_TaxonId",
                table: "Observations");

            migrationBuilder.DropColumn(
                name: "TaxonId",
                table: "Observations");
        }
    }
}
