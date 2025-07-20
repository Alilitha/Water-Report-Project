using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WaterReport
{
    public partial class PlumberFeed : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadIssues();
            }
        }
        private void LoadIssues()
        {
           // string town = Session["Town"]?.ToString(); // Or get it from query string
            string connStr = ConfigurationManager.ConnectionStrings["DripAlertDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT IssueID, UserID, Title, Description, Latitude, Longitude, ImagePath, Street, Suburb, City, PostalCode FROM WaterIssues";


                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    //cmd.Parameters.AddWithValue("@Town", town);
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    rptIssues.DataSource = reader;
                    rptIssues.DataBind();
                }
            }
        }
        protected void rptIssues_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var dataRecord = (System.Data.IDataRecord)e.Item.DataItem;

                string imagePaths = dataRecord["ImagePath"]?.ToString() ?? string.Empty;
                string[] images = imagePaths.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                // Only bind the first 2 images
                var imageRepeater = (Repeater)e.Item.FindControl("rptImages");
                imageRepeater.DataSource = images.Take(2); // Limit to 2
                imageRepeater.DataBind();

                // Optional: You can also add a "View More" Literal if needed
                if (images.Length > 2)
                {
                    // Add dynamic label or control to show "+ View More"
                }
            }
        }



        protected void ViewLocation_Click(object sender, EventArgs e)
        {
            string[] addressParts = ((System.Web.UI.WebControls.Button)sender).CommandArgument.Split(',');

            string street = addressParts[0];
            string suburb = addressParts[1];
            string city = addressParts[2];
            string postalCode = addressParts[3];

            string fullAddress = $"{street}, {suburb}, {city}, {postalCode}";

            // Redirect to map page using address instead of lat/lng
            Response.Redirect($"ViewLocation.aspx?address={HttpUtility.UrlEncode(fullAddress)}");
        }

        protected void ChatOwner_Click(object sender, EventArgs e)
        {
            string username = ((System.Web.UI.WebControls.Button)sender).CommandArgument;
            Response.Redirect($"Chat.aspx?user={username}");
        }

        protected void MakeQuotation_Click(object sender, EventArgs e)
        {
            string issueId = ((System.Web.UI.WebControls.Button)sender).CommandArgument;
            Response.Redirect($"CreateQuotation.aspx?issueId={issueId}");
        }
    }
}