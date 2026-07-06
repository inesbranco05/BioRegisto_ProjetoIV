namespace BioRegisto.API.Models;

public class Observation
{
    public int Id { get; set; }

    public string ScientificName { get; set; } = "";

    public string CommonName { get; set; } = "";

    public double Latitude { get; set; }

    public double Longitude { get; set; }

    public string Status { get; set; } = "Pending";

    public DateTime CreatedAt { get; set; }
}