<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PostIssue.aspx.cs" Inherits="WaterReport.PostIssue" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Post Water Issue</title>
    <style>
        body { font-family: Arial; margin: 0; padding: 0; background-color: #f4f4f4; }
        .container { max-width: 600px; margin: 30px auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        input, textarea, select {
            width: 100%; padding: 10px; margin-bottom: 10px;
            border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;
        }
        .form-title { text-align: center; margin-bottom: 20px; }
        .btn-submit { background-color: #007bff; color: #fff; border: none; cursor: pointer; }
        .btn-submit:hover { background-color: #0056b3; }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="container">
        <h3 class="form-title">Post a Water Issue</h3>

        <asp:TextBox ID="txtTitle" runat="server" placeholder="Issue Title" /><br />

        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" placeholder="Describe the issue..." /><br />

        <asp:FileUpload ID="fuImage" runat="server" /><br />

        <asp:TextBox ID="txtStreet" runat="server" placeholder="Street Address (e.g., 123 Main Rd)" /><br />
        <asp:TextBox ID="txtSuburb" runat="server" placeholder="Suburb" /><br />
        <asp:TextBox ID="txtCity" runat="server" placeholder="City" /><br />
        <asp:TextBox ID="txtPostalCode" runat="server" placeholder="Postal Code" /><br />

        <!-- Optional: You may still use hidden fields for future use -->
        <asp:HiddenField ID="hfLatitude" runat="server" />
        <asp:HiddenField ID="hfLongitude" runat="server" />

        <asp:Button ID="btnPost" runat="server" Text="Post Issue" CssClass="btn-submit" OnClick="btnPost_Click"  />
    </form>
</body>
</html>
