# Pin npm packages by running ./bin/importmap

pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin 'bootstrap', to: 'https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.js'
pin '@popperjs/core', to: 'https://ga.jspm.io/npm:@popperjs/core@2.11.8/dist/umd/popper.min.js'
pin '@github/auto-complete-element', to: 'https://cdn.skypack.dev/@github/auto-complete-element'
pin 'blacklight', to: 'https://unpkg.com/blacklight-frontend@8.3.0/dist/blacklight.js'
pin 'ol', to: 'https://unpkg.com/ol@8.1.0/dist/ol.js'
pin 'ol', to: 'https://ga.jspm.io/npm:ol@8.1.0/index.js'
pin 'ol/layer/Tile', to: 'https://ga.jspm.io/npm:ol@8.1.0/layer/Tile.js'
pin 'ol/source/XYZ', to: 'https://ga.jspm.io/npm:ol@8.1.0/source/XYZ.js'
pin 'ol/format/GeoJSON', to: 'https://ga.jspm.io/npm:ol@8.1.0/format/GeoJSON.js'
pin 'ol/control', to: 'https://ga.jspm.io/npm:ol@8.1.0/control.js'
pin 'rbush', to: 'https://unpkg.com/rbush@4.0.0/index.js'
pin 'leaflet', to: 'https://ga.jspm.io/npm:leaflet@1.7.1/dist/leaflet.js'
pin 'react', to: 'https://cdn.skypack.dev/react@18.2/umd/react.production.min.js'
pin 'react-dom', to: 'https://cdn.skypack.dev/react-dom@18.2/umd/react-dom.production.min.js'
pin '@geoblacklight/frontend', to: 'https://unpkg.com/@geoblacklight/frontend@5.0.0-alpha.4/app/assets/javascripts/geoblacklight/geoblacklight.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript'
