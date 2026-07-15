config = Geoblacklight.configuration
config.relationships_shown[:member_of_ancestors].icon = 'collection'

leaflet = config.leaflet_options
leaflet.bounds_overlay = {
  INDEX: { color: '#175E54' },
  SHOW: { color: '#175E54' },
  STATIC_MAP: { color: '#175E54' }
}
leaflet.layers.index = {
  DEFAULT: { color: '#006CB8' },
  UNAVAILABLE: { color: '#B1040E' },
  SELECTED: { color: 'yellow' }
}
leaflet.sleep.sleep = false
