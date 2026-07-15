namespace BioRegisto.API.Models;

public class Taxon
{
    public int Id { get; set; }

    public string Name { get; set; } =
        string.Empty;

    public string Rank { get; set; } =
        string.Empty;

    public int? ParentId { get; set; }

    public Taxon? Parent { get; set; }

    public List<Taxon> Children { get; set; } =
        new();
}