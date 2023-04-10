//= require handlebars.runtime
//= require geoblacklight/geoblacklight
//= require geoblacklight/basemaps
//= require geoblacklight/controls
//= require geoblacklight/viewers
//= require geoblacklight/modules
//= require geoblacklight/downloaders

//= require leaflet-iiif

GeoBlacklight.Basemaps['OpenStreetMap.HOT'] = L.tileLayer(
    'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
      maxZoom: 19,
      noWrap: true,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>',
    }
);
