config = Geoblacklight.configuration
config.relationships_shown[:member_of_ancestors].icon = 'collection'

leaflet = config.leaflet_options
leaflet.bounds_overlay = {
  INDEX: { color: '#175E54' },
  SHOW: { color: '#175E54' },
  STATIC_MAP: { color: '#175E54' }
}
leaflet.layers.index = {
  DEFAULT: { color: '#006CB8', weight: 1, radius: 4 },
  UNAVAILABLE: { color: '#B1040E', weight: 1, radius: 4 },
  SELECTED: { color: 'yellow', weight: 1, radius: 4 }
}
leaflet.sleep.sleep = false
config.vector_download_formats = %w[Shapefile CSV GeoJSON]
