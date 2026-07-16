public class ValidateObservationDto
{
    public int TaxonId { get; set; }

    public string CommonName { get; set; }
        = string.Empty;

    public string ScientificName { get; set; }
        = string.Empty;

    public string? Notes { get; set; }
}