# Pin npm packages by running ./bin/importmap

# Hotwire
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

# Bootstrap
pin '@popperjs/core', to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8'
pin 'bootstrap', to: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/+esm'

# Blacklight
pin 'blacklight', to: 'https://cdn.jsdelivr.net/npm/blacklight-frontend@8.4.0/app/assets/javascripts/blacklight/blacklight.js'
pin '@github/auto-complete-element', to: 'https://cdn.jsdelivr.net/npm/@github/auto-complete-element@3.8.0/+esm'

# EarthWorks
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript'
