namespace BioRegisto.API.Models;

public class Observation
{
    public int Id { get; set; }

    public string ScientificName { get; set; } = "";

    public string CommonName { get; set; } = "";

    public double Latitude { get; set; }

    public double Longitude { get; set; }

    public string Status { get; set; } = "Pending";

    public string? ImageUrl { get; set; }

    public DateTime CreatedAt { get; set; }

    public int? UserId { get; set; }

    public User? User { get; set; }

    public int? TaxonId { get; set; }

    public Taxon? Taxon { get; set; }

    public string? ValidationNotes { get; set; }

    public string? RejectionReason { get; set; }

    public int? ValidatedByUserId { get; set; }

    public DateTime? ValidatedAt { get; set; }
}