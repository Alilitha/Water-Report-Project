<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PlumberFeed.aspx.cs" Inherits="WaterReport.PlumberFeed" %>

<html>
<head runat="server">
    <title>Nearby Water Issues - DripAlert</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        .description { overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }
        .image-preview { width: 100%; height: auto; margin-bottom: 5px; }
        .more-images { font-size: 1.2rem; color: #007bff; cursor: pointer; }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container mt-4">
            <h2 class="mb-4">Nearby Water Issues</h2>
           <asp:Repeater ID="rptIssues" runat="server" OnItemDataBound="rptIssues_ItemDataBound">
    <ItemTemplate>
        <div class="card mb-4 shadow-sm">
            <div class="card-body">
                <h5 class="card-title"><%# Eval("Title") %></h5>
                <p class="card-text description"><%# Eval("Description") %></p>
                <a href="javascript:void(0);" class="see-more text-primary d-block mb-2">See more</a>

                <!-- Images repeater -->
                <div class="row">
                    <asp:Repeater ID="rptImages" runat="server">
                        <ItemTemplate>
                            <div class="col-6 mb-2">
                            <img src='<%# Container.DataItem.ToString().Replace("~", "") %>' class="image-preview img-fluid rounded" />

                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="mt-3 d-flex justify-content-between">
<asp:Button CssClass="btn btn-outline-primary btn-sm"
    Text="View Location"
    CommandArgument='<%# Eval("Street") + "," + Eval("Suburb") + "," + Eval("City") + "," + Eval("PostalCode") %>'
    OnClick="ViewLocation_Click" runat="server" />
                    <asp:Button CssClass="btn btn-outline-success btn-sm" Text="Chat with Owner" CommandArgument='<%# Eval("UserID") %>' OnClick="ChatOwner_Click" runat="server" />
                    <asp:Button CssClass="btn btn-outline-warning btn-sm" Text="Make Quotation" CommandArgument='<%# Eval("IssueID") %>' OnClick="MakeQuotation_Click" runat="server" />
                </div>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

        </div>
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $('.see-more').on('click', function () {
            $(this).prev('.description').css({ '-webkit-line-clamp': 'unset' });
            $(this).hide();
        });

        $('.more-images').on('click', function () {
            alert('Show full image gallery modal or redirect to full issue view.');
        });
    </script>
</body>
</html>