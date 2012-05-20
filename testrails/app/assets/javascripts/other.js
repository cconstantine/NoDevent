var map = null;
$(function () {
    // Define the map to use from MapBox
    // This is the TileJSON endpoint copied from the embed button on your map
    var url = 'http://a.tiles.mapbox.com/v3/cconstantine.map-gyhx1cl1.jsonp';
    
    // Make a new Leaflet map in your container div
    map = new L.Map('mapbox').setView(new L.LatLng(39.572, -95.449), 4);
    
    // Get metadata about the map from MapBox
    wax.tilejson(url, function(tilejson) {
                   map.addLayer(new wax.leaf.connector(tilejson));
                 });

});

function updateLoc(url, data) {
  $(function() {
      navigator.geolocation.watchPosition(
        function(location) {
          console.log(location);
          $.post(url, {user : user, loc : location});
        });
    });
}

function onJoin(name, room) {

  var users = {};
  console.log(name);
  room.on('location',
          function(data) {
            var circle = users[data.user.name];
            var coords = data.loc.coords;

            if (!circle) {
              var circleLocation = new L.LatLng(coords.latitude, coords.longitude),
              circleOptions = {
                color: 'blue',
                fillColor: 'blue',
                fillOpacity: 0.5
              };
              
              circle = new L.Circle(circleLocation, coords.accuracy, circleOptions);
              users[data.user.name] = circle; 
              map.addLayer(circle);
            } else {
              var latlng = new L.LatLng( coords.latitude, coords.longitude );
              circle.setLatLng(latlng, coords.accuracy);
            }
          });
  
  var user_counts = {};
  room.users.on(
    'join',
    function(user) {
      user_counts[user.name] |= 0;
      user_counts[user.name]++;
      console.log("joining ",  room.name, user.name);
    });

  room.users.on(
    'members', 
    function(members) {
      for(var i in members) {
        var member = members[i];
        if (!user_counts[member])
          user_counts[member] = 1;
      }
      console.log('members', members);
    });
  room.users.on(
    'leave',
    function(user) {
      console.log("leaving ",  room.name, user.name);
      user_counts[user.name]++;
      if (user_counts[user.name] == 0) {        
        delete user_counts[user.name];

        var circle = users[user.name];
        map.removeLayer(circle);
      }
    });
  
}