# Pin npm packages by running ./bin/importmap

# Hotwire
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

# Bootstrap
pin '@popperjs/core', to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8'
pin 'bootstrap', to: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/+esm'

# Blacklight
pin '@github/auto-complete-element', to: 'https://cdn.jsdelivr.net/npm/@github/auto-complete-element@3.8.0/+esm'

# OpenLayers temporary fix
pin 'ol-pmtiles', to: 'https://cdn.jsdelivr.net/npm/ol-pmtiles@0.3.0/+esm'

# Leaflet temporary fix
pin 'leaflet', to: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet-src.esm.js'
pin 'esri-leaflet', to: 'https://cdn.jsdelivr.net/npm/esri-leaflet@3.0.19/+esm'
pin 'leaflet.fullscreen', to: 'https://cdn.jsdelivr.net/npm/leaflet.fullscreen@5.3.0/+esm'
# We effectively don't use this but GBL's underlying version keeps throwing errors otherwise
pin 'leaflet-fullscreen', to: 'https://cdn.jsdelivr.net/npm/leaflet.fullscreen@5.3.0/+esm'

# EarthWorks
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript'
# chart.js is dependency of blacklight-range-limit, currently is not working
# as vendored importmaps, but instead must be pinned to CDN. You may want to update
# versions perioidically.
pin 'chart.js', to: 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm'
# single dependency of chart.js:
pin '@kurkle/color', to: 'https://cdn.jsdelivr.net/npm/@kurkle/color@0.4.0/dist/color.esm.min.js'
