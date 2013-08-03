var oldOnload = window.onload;
window.onload = function() {
  if(oldOnload) {
    oldOnload();
  }
  if (GBrowserIsCompatible()) {
    var map = new GMap2(document.getElementById("map"));
    var lat = parseFloat(document.getElementById('lat').innerHTML);
    var lng = parseFloat(document.getElementById('lng').innerHTML);
    var latlng = new GLatLng(lat,lng);
    var info = document.getElementById('info');
    var marker = new GMarker(latlng);

    map.setCenter(latlng,14);
    marker.bindInfoWindow(info);
    map.addOverlay(marker);
    marker.openInfoWindow(info);map.addControl(new GLargeMapControl());
    map.addControl(new GMapTypeControl());
  }
};

