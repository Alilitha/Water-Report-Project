using System;
using System.Net;
using System.Web.Script.Serialization;

public class GeoCoordinates
{
    public double lat { get; set; }
    public double lon { get; set; }
}

public class GeoHelper
{
    public static GeoCoordinates GetCoordinatesFromAddress(string address)
    {
        try
        {
            string url = $"https://nominatim.openstreetmap.org/search?format=json&q={Uri.EscapeDataString(address)}";
            using (WebClient client = new WebClient())
            {
                client.Headers.Add("User-Agent", "DripAlert/1.0");
                string json = client.DownloadString(url);
                var results = new JavaScriptSerializer().Deserialize<dynamic[]>(json);

                if (results.Length > 0)
                {
                    return new GeoCoordinates
                    {
                        lat = Convert.ToDouble(results[0]["lat"]),
                        lon = Convert.ToDouble(results[0]["lon"])
                    };
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Geocoding error: " + ex.Message);
        }

        return null;
    }
}
