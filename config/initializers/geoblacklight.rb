# Nothing left to configure here after the GeoBlacklight 6 viewer rework, but the
# two things this file used to set are worth a pointer:
#
# * Map colours moved from Ruby (config.leaflet_options) to the --ogm-* CSS custom
#   properties that ogm-viewer reads; ours are in app/assets/stylesheets/earthworks.css.
#   Basemaps are now light_basemap_url / dark_basemap_url, each a URL to a MapLibre
#   style document, and are left unset so the viewer uses its own defaults.
#
# * Per-relationship icons are gone. Related records are labelled with a
#   resource-class badge (Geoblacklight::HeaderBadgesComponent) instead.
