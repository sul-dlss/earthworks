# Pin npm packages by running ./bin/importmap

# Hotwire
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

# Bootstrap
pin '@popperjs/core', to: 'https://cdn.skypack.dev/@popperjs/core@2.11.8/dist/umd/popper.min.js'
pin 'bootstrap', to: 'https://cdn.skypack.dev/bootstrap@5.3.3/dist/js/bootstrap.bundle.js'

# Blacklight
pin 'blacklight', to: 'https://cdn.skypack.dev/blacklight-frontend@8.3.0/dist/blacklight.js'
pin '@github/auto-complete-element', to: 'https://cdn.skypack.dev/@github/auto-complete-element'

# GeoBlacklight
pin 'ol', to: 'https://cdn.skypack.dev/ol@8.1.0'
pin 'ol/', to: 'https://cdn.skypack.dev/ol@8.1.0/'
pin 'ol-pmtiles', to: 'https://cdn.skypack.dev/ol-pmtiles@0.3.0/dist/olpmtiles.js'
pin 'leaflet', to: 'https://cdn.skypack.dev/leaflet@1.9.4'
pin 'leaflet-fullscreen', to: 'https://cdn.skypack.dev/leaflet-fullscreen@1.0.2'
pin 'geoblacklight', to: 'geoblacklight.js' # TODO: once published to npm, update to CDN url

# Earthworks
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript'
