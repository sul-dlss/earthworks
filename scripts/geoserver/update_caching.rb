require 'faraday'
require 'nokogiri'

##
# This script updates the caching default for each individual layer that we
# host. Unfortunately there is no global way to set this, so it has to happen
# on a per layer basis.

geoserver_url = ENV.fetch('GEOSERVER_URL', nil)

raise('GEOSERVER_URL not provided') unless geoserver_url
raise('GEOSERVER_USER not provided') unless ENV['GEOSERVER_USER']
raise('GEOSERVER_PASS not provided') unless ENV['GEOSERVER_PASS']

puts "Updating cache defaults for all layers on #{geoserver_url}"

conn = Faraday.new(url: geoserver_url) do |faraday|
  faraday.basic_auth(ENV.fetch('GEOSERVER_USER', nil), ENV.fetch('GEOSERVER_PASS', nil))
  faraday.adapter :net_http
end

layers_response = conn.get do |req|
  req.url 'geoserver/rest/layers.xml'
  req.options.timeout = 30
end

layer_names = Nokogiri::XML(layers_response.body).xpath('//layer/name').map(&:text)
puts "Found #{layer_names.length} layers"
Nokogiri::XML(layers_response.body).xpath('//layer').each do |layer|
  name = layer.xpath('name').text
  layer_rest = layer.xpath('atom:link', atom: 'http://www.w3.org/2005/Atom').attribute('href').to_s

  layer_response = conn.get do |req|
    req.url layer_rest.gsub(geoserver_url, '')
  end.body

  layer_update = Nokogiri::XML(layer_response).xpath('//resource/atom:link', atom: 'http://www.w3.org/2005/Atom').attribute('href').to_s
  current_config = conn.get do |req|
    req.url layer_update.gsub(geoserver_url, '')
  end.body
  metadata = Nokogiri::XML.fragment(
    <<~XML
      <metadata>
        <entry key="cacheAgeMax">86400</entry>
        <entry key="cachingEnabled">true</entry>
      </metadata>
    XML
  )
  new_config = Nokogiri::XML(current_config)
  # Replace existing metadata element
  if new_config.search('metadata').first
    new_config.search('metadata').first.replace(metadata)
  else
    # or just put it at the root
    new_config.xpath('/').first.root << metadata
  end
  print "Updating #{name} at #{layer_update}"
  print ' ... '
  update = conn.put do |req|
    req.url layer_update.gsub(geoserver_url, '')
    req.headers['Content-Type'] = 'text/xml'
    req.body = new_config.to_xml
  end
  print update.status
  puts ''
end
