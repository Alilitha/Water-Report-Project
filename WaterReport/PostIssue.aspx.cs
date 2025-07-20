using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Add the missing namespace or class definition for GeoHelper and GeoCoordinates
namespace WaterReport
{
    public static class GeoHelper
    {
        public static GeoCoordinates GetCoordinatesFromAddress(string address)
        {
            // Mock implementation for demonstration purposes
            // Replace this with actual logic to fetch coordinates from an address
            return new GeoCoordinates { lat = -25.7479, lon = 28.2293 }; // Example coordinates
        }
    }

    public class GeoCoordinates
    {
        public double lat { get; set; }
        public double lon { get; set; }
    }

    public partial class PostIssue : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            // Existing code remains unchanged
            string title = txtTitle.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string street = txtStreet.Text.Trim();
            string suburb = txtSuburb.Text.Trim();
            string city = txtCity.Text.Trim();
            string postal = txtPostalCode.Text.Trim();
            int userId = 1; // Replace with actual logged-in user ID in real app

            string fullAddress = $"{street}, {suburb}, {city}, {postal}, South Africa";

            GeoCoordinates coords = GeoHelper.GetCoordinatesFromAddress(fullAddress);

            if (coords == null)
            {
                Response.Write("<script>alert('Could not determine location from address.');</script>");
                return;
            }

            string imagePath = "";
            if (fuImage.HasFile)
            {
                string uploadFolder = Server.MapPath("~/Uploads/");
                if (!Directory.Exists(uploadFolder))
                    Directory.CreateDirectory(uploadFolder);

                string fileName = Path.GetFileName(fuImage.FileName);
                string filePath = Path.Combine(uploadFolder, fileName);
                fuImage.SaveAs(filePath);
                imagePath = "~/Uploads/" + fileName;
            }

            string connStr = ConfigurationManager.ConnectionStrings["DripAlertDB"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
        INSERT INTO WaterIssues 
        (UserID, Title, Description, ImagePath, Latitude, Longitude, Timestamp, Street, Suburb, City, PostalCode)
        VALUES 
        (@UserID, @Title, @Desc, @ImagePath, @Latitude, @Longitude, @Timestamp, @Street, @Suburb, @City, @PostalCode)";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@Desc", desc);
                    cmd.Parameters.AddWithValue("@ImagePath", imagePath);
                    cmd.Parameters.AddWithValue("@Latitude", coords.lat);
                    cmd.Parameters.AddWithValue("@Longitude", coords.lon);
                    cmd.Parameters.AddWithValue("@Timestamp", DateTime.Now);

                    // 🆕 Address Fields
                    cmd.Parameters.AddWithValue("@Street", txtStreet.Text.Trim());
                    cmd.Parameters.AddWithValue("@Suburb", txtSuburb.Text.Trim());
                    cmd.Parameters.AddWithValue("@City", txtCity.Text.Trim());
                    cmd.Parameters.AddWithValue("@PostalCode", txtPostalCode.Text.Trim());

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }


            Response.Write("<script>alert('Issue posted successfully!'); window.location='ViewFeed.aspx';</script>");
        }
    }
}