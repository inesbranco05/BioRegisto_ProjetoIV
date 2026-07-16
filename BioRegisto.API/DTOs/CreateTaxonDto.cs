namespace BioRegisto.API.DTOs;

public class CreateTaxonDto
{
    public string Name { get; set; } = string.Empty;

    public string Rank { get; set; } = string.Empty;

    public int? ParentId { get; set; }

    public string? CommonName { get; set; }
}