<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewLocation.aspx.cs" Inherits="WaterReport.ViewLocation" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Issue Location</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        #map { height: 500px; width: 100%; }
        #distance { margin-top: 10px; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="map"></div>
        <div id="distance"></div>
    </form>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Step 1: Get coordinates from query string
        const ownerLat = parseFloat('<%= Request.QueryString["lat"] ?? "-32.9962" %>');  // Default: UFH East London
        const ownerLon = parseFloat('<%= Request.QueryString["lng"] ?? "27.9054" %>');

        let plumberLat = null;
        let plumberLon = null;

        // Step 2: Get plumber's real-time location
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                pos => {
                    plumberLat = pos.coords.latitude;
                    plumberLon = pos.coords.longitude;

                    const map = L.map('map').setView([plumberLat, plumberLon], 14);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

                    // ✅ Add Plumber Marker
                    L.marker([plumberLat, plumberLon])
                        .addTo(map)
                        .bindPopup("Your Location (Plumber)")
                        .openPopup();

                    // ✅ Add House Owner Marker
                    L.marker([ownerLat, ownerLon])
                        .addTo(map)
                        .bindPopup("Issue Location (House Owner)");

                    // ✅ Draw line
                    const routeLine = L.polyline([[plumberLat, plumberLon], [ownerLat, ownerLon]], { color: 'blue' }).addTo(map);
                    map.fitBounds(routeLine.getBounds());

                    // ✅ Calculate and show distance
                    const distance = getDistance(plumberLat, plumberLon, ownerLat, ownerLon);
                    document.getElementById("distance").innerText = `Distance to issue: ${distance.toFixed(2)} km`;
                },
                err => {
                    alert("Could not get your location. Reason: " + err.message);
                },
                {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 0
                }
            );
        } else {
            alert("Geolocation is not supported by your browser.");
        }

        // ✅ Helper function: Haversine distance
        function getDistance(lat1, lon1, lat2, lon2) {
            const R = 6371; // Earth radius in km
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLon = (lon2 - lon1) * Math.PI / 180;
            const a = Math.sin(dLat / 2) ** 2 +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                Math.sin(dLon / 2) ** 2;
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c;
        }
    </script>
</body>
</html>