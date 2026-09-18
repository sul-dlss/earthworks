# Configuration for GeoBlacklight; see:
# https://github.com/geoblacklight/geoblacklight/blob/main/lib/geoblacklight/configuration.rb
config = Geoblacklight.configuration

# Supply our CARTO API key so basemaps don't get watermarked. See:
# https://docs.carto.com/faqs/carto-basemaps
#
# It's OK for this to be public on the client side because it's restricted to
# Stanford origins (*.stanford.edu) in our CARTO configuration.
CARTO_API_KEY = 'cb1_3pzn_1_1af10a23e7b04a57f0e9e5f4'.freeze

# We use 'positron' for light basemaps and 'darkMatter' for dark ones; this
# is the same defaults as ogm-viewer, just with an API key appended.
#
# These URLs must point to MapLibre JSON style documents. For CARTO basemaps,
# the API key gets appended; for others it's not required.
#
# For now, appending the key to the vector basemaps actually 403s, because CARTO
# apparently hasn't turned it on yet. When the watermark shows up again, swap
# these for the versions below that send the API key.
config.light_basemap_url = 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
config.dark_basemap_url = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json'
#
# config.light_basemap_url = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json?key=#{CARTO_API_KEY}"
# config.dark_basemap_url = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json?key=#{CARTO_API_KEY}"
