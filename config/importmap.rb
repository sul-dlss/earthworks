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

# EarthWorks
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript'
# chart.js is dependency of blacklight-range-limit, currently is not working
# as vendored importmaps, but instead must be pinned to CDN. You may want to update
# versions perioidically.
pin 'chart.js', to: 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm'
# single dependency of chart.js:
pin '@kurkle/color', to: 'https://cdn.jsdelivr.net/npm/@kurkle/color@0.4.0/dist/color.esm.min.js'
