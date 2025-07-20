<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Map.aspx.cs" Inherits="WaterReport.Map" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Improved GPS Navigation</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { margin: 0; font-family: Arial, sans-serif; }
        #map { height: 500px; width: 100%; margin-top: 10px; }
        #txtSearch { width: 300px; padding: 8px; margin-bottom: 5px; }
        #suggestions {
            position: absolute;
            background: white;
            border: 1px solid #ccc;
            max-height: 150px;
            overflow-y: auto;
            width: 300px;
            z-index: 1000;
        }
        #suggestions div {
            padding: 6px;
            cursor: pointer;
        }
        #suggestions div:hover {
            background-color: #f0f0f0;
        }
        #route-info {
            margin-top: 10px;
            padding: 10px;
            background: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 6px;
            max-width: 700px;
        }
        .instruction {
            margin: 4px 0;
        }
        #startNavBtn {
            margin-top: 10px;
            padding: 10px 20px;
        }
    </style>
</head>
<body>
<form id="form1" runat="server" style="padding: 10px;">
    <input id="txtSearch" type="text" placeholder="Search destination near East London..." autocomplete="off" />
    <div id="suggestions"></div>
    <asp:HiddenField ID="hfApiKey" runat="server" Value="5b3ce3597851110001cf6248ddb35fb686e5400eb140e034e125d29b" />
    <div id="map"></div>
    <div id="route-info"></div>
    <button id="startNavBtn" type="button">Start Navigation</button>
</form>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    let map = L.map('map').setView([-33.0153, 27.9116], 13); // East London center
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

    let userMarker, destinationMarker;
    let routeLayers = [], userLat = null, userLon = null;
    let destinationCoords = null, navSteps = [], currentStepIndex = 0, navigationActive = false;

    const txtSearch = document.getElementById("txtSearch");
    const suggestionsBox = document.getElementById("suggestions");
    const routeInfo = document.getElementById("route-info");
    const apiKey = document.getElementById('<%= hfApiKey.ClientID %>').value;

    const userIcon = L.icon({ iconUrl: 'https://cdn-icons-png.flaticon.com/512/149/149071.png', iconSize: [30, 30], iconAnchor: [15, 30] });
    const destIcon = L.icon({ iconUrl: 'https://cdn-icons-png.flaticon.com/512/684/684908.png', iconSize: [30, 30], iconAnchor: [15, 30] });

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(pos => {
            userLat = pos.coords.latitude;
            userLon = pos.coords.longitude;
            map.setView([userLat, userLon], 14);
            userMarker = L.marker([userLat, userLon], { icon: userIcon }).addTo(map).bindPopup("You are here").openPopup();
        }, err => alert("Could not get your location: " + err.message), { enableHighAccuracy: true });
    } else {
        alert("Geolocation not supported by your browser.");
    }

    txtSearch.addEventListener("input", function () {
        const query = txtSearch.value.trim();
        if (query.length < 2 || userLat === null || userLon === null) {
            suggestionsBox.innerHTML = "";
            return;
        }
        const baseLocation = "East London, Eastern Cape, South Africa";
        const fullQuery = `${query}, ${baseLocation}`;

        fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(fullQuery)}&addressdetails=1&limit=5`)
            .then(res => res.json())
            .then(data => {
                suggestionsBox.innerHTML = "";
                data.forEach(loc => {
                    const item = document.createElement("div");
                    item.textContent = loc.display_name;
                    item.onclick = () => {
                        txtSearch.value = loc.display_name;
                        suggestionsBox.innerHTML = "";
                        destinationCoords = [parseFloat(loc.lat), parseFloat(loc.lon)];
                        if (destinationMarker) map.removeLayer(destinationMarker);
                        destinationMarker = L.marker(destinationCoords, { icon: destIcon }).addTo(map).bindPopup(loc.display_name).openPopup();
                        drawRoute(userLat, userLon, destinationCoords[0], destinationCoords[1]);
                    };
                    suggestionsBox.appendChild(item);
                });
            });
    });

    function drawRoute(startLat, startLon, endLat, endLon) {
        const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${apiKey}&start=${startLon},${startLat}&end=${endLon},${endLat}`;
        fetch(url)
            .then(res => res.json())
            .then(data => {
                routeLayers.forEach(layer => map.removeLayer(layer));
                routeLayers = [];
                const coords = data.features[0].geometry.coordinates.map(p => [p[1], p[0]]);
                const polyline = L.polyline(coords, { color: 'blue', weight: 5 }).addTo(map);
                routeLayers.push(polyline);
                map.fitBounds(polyline.getBounds());
                const steps = data.features[0].properties.segments[0].steps;
                navSteps = steps;
                currentStepIndex = 0;
                routeInfo.innerHTML = `<strong>Distance:</strong> ${(data.features[0].properties.summary.distance / 1000).toFixed(2)} km<br>
                                       <strong>Time:</strong> ${Math.round(data.features[0].properties.summary.duration / 60)} min<br><br>
                                       <strong>Instructions:</strong><br>` +
                    steps.map((s, i) => `<div class="instruction">${i + 1}. ${s.instruction}</div>`).join('');
            }).catch(err => alert("Could not calculate route."));
    }

    function speakNow(text) {
        if ('speechSynthesis' in window) {
            const utter = new SpeechSynthesisUtterance(text);
            utter.rate = 1;
            utter.pitch = 1;
            speechSynthesis.speak(utter);
        }
    }

    function getDistance(lat1, lon1, lat2, lon2) {
        const R = 6371;
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLon = (lon2 - lon1) * Math.PI / 180;
        const a = Math.sin(dLat / 2) ** 2 +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) ** 2;
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    document.getElementById("startNavBtn").addEventListener("click", () => {
        if (!navSteps.length) return alert("Load a destination first.");
        navigationActive = true;
        alert("Navigation started!");
    });

    window.onload = () => map.invalidateSize();
</script>
</body>
</html>