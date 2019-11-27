require 'faraday'
require 'nokogiri'

##
# This script updates the default layer styling for raster data that we
# host. We only do this for layers that for some reason the styling is errored.

geoserver_url = ENV['GEOSERVER_URL']

$stdout.reopen("tmp/raster.log", "w")
$stdout.sync = true
$stderr.reopen($stdout)

raise('GEOSERVER_URL not provided') unless geoserver_url
raise('GEOSERVER_USER not provided') unless ENV['GEOSERVER_USER']
raise('GEOSERVER_PASS not provided') unless ENV['GEOSERVER_PASS']

puts "Updating WMS default style for all raster layers on #{geoserver_url}"

conn = Faraday.new(url: geoserver_url) do |faraday|
  faraday.basic_auth(ENV['GEOSERVER_USER'], ENV['GEOSERVER_PASS'])
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
  # just a test case
  # next unless name == 'dr305kh8234'

  layer_rest = layer.xpath('atom:link', atom: 'http://www.w3.org/2005/Atom').attribute('href').to_s

  layer_response = conn.get do |req|
    req.url layer_rest.gsub(geoserver_url, '')
  end.body
  parsed_response = Nokogiri::XML(layer_response)
  if parsed_response.xpath('//type').text == 'RASTER'
    print "#{name} is a raster"
    style = parsed_response.xpath('//defaultStyle').text.strip
    print " - #{style}"
    if style == ''
      print " - style is blank and needs updating, setting to raster"
      raster_style =
        <<~XML
          <layer>
            <defaultStyle>
              <name>raster</name>
            </defaultStyle>
          </layer>
        XML
        update = conn.put do |req|
          req.url layer_rest.gsub(geoserver_url, '')
          req.headers['Content-Type'] = 'text/xml'
          req.body = raster_style
        end
        print update.status
    end
    print "\n"
  end
end
