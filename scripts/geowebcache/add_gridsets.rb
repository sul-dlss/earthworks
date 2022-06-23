require 'faraday'
require 'nokogiri'

##
# This script updates the GeoWebCache tile caching gridsets for every layer
# within a GeoServer node. This is necessary for existing layers that may have
# not been created with a default gridset that was added after creation. The
# original need here was part of adding GeoWebCache for 512x512 tiles.

geoserver_url = ENV.fetch('GEOSERVER_URL', nil)

raise('GEOSERVER_URL not provided') unless geoserver_url
raise('GEOSERVER_USER not provided') unless ENV['GEOSERVER_USER']
raise('GEOSERVER_PASS not provided') unless ENV['GEOSERVER_PASS']

puts "Updating gridsets for all layers on #{geoserver_url}"

conn = Faraday.new(url: geoserver_url) do |faraday|
  faraday.basic_auth(ENV.fetch('GEOSERVER_USER', nil), ENV.fetch('GEOSERVER_PASS', nil))
  faraday.adapter :net_http
end

layers_response = conn.get do |req|
  req.url 'geoserver/gwc/rest/layers.xml'
  req.options.timeout = 30
end

layer_names = Nokogiri::XML(layers_response.body).xpath('//layer/name').map(&:text)
puts "Found #{layer_names.length} layers"
layer_names.each do |name|
  current_config = conn.get do |req|
    req.url "geoserver/gwc/rest/layers/#{name}.xml"
    req.options.timeout = 15
  end.body
  grid_subsets = Nokogiri::XML.fragment(
    <<~XML
      <gridSubsets>
          <gridSubset>
            <gridSetName>EPSG:900913</gridSetName>
          </gridSubset>
          <gridSubset>
            <gridSetName>EPSG:4326</gridSetName>
          </gridSubset>
          <gridSubset>
            <gridSetName>EPSG:900913 - 512</gridSetName>
          </gridSubset>
          <gridSubset>
            <gridSetName>EPSG:3857 - 512</gridSetName>
          </gridSubset>
          <gridSubset>
            <gridSetName>EPSG:4326 - 512</gridSetName>
          </gridSubset>
        </gridSubsets>
    XML
  )
  new_config = Nokogiri::XML(current_config)
  new_config.search('gridSubsets').first.replace(grid_subsets)

  print "Updating #{name} at #{geoserver_url}/geoserver/gwc/rest/layers/#{name}.xml"
  print '...'
  update = conn.post do |req|
    req.url "geoserver/gwc/rest/layers/#{name}.xml"
    req.headers['Content-Type'] = 'text/xml'
    req.body = new_config.to_xml
  end
  print update.status
  puts ''
end
