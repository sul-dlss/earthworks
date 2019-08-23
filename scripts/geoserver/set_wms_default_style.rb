require 'faraday'
require 'nokogiri'

##
# This script updates the default layer styling for vector data that we
# host. Unfortunately there is no global way to set this, so it has to happen
# on a per layer basis.

geoserver_url = ENV['GEOSERVER_URL']

raise('GEOSERVER_URL not provided') unless geoserver_url
raise('GEOSERVER_USER not provided') unless ENV['GEOSERVER_USER']
raise('GEOSERVER_PASS not provided') unless ENV['GEOSERVER_PASS']

puts "Updating WMS default style for all vector layers on #{geoserver_url}"

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
  layer_rest = layer.xpath('atom:link', atom: 'http://www.w3.org/2005/Atom').attribute('href').to_s

  layer_response = conn.get do |req|
    req.url layer_rest.gsub(geoserver_url, '')
  end.body
  parsed_response = Nokogiri::XML(layer_response)
  if parsed_response.xpath('//type').text == 'VECTOR'
    print "#{name} is a vector"
    style = parsed_response.xpath('//defaultStyle').text.strip
    unless style.length > 0
      print ' no defaultStyle is set setting to generic '
      generic_style =
        <<~XML
          <layer>
            <defaultStyle>
              <name>generic</name>
            </defaultStyle>
          </layer>
        XML
      update = conn.put do |req|
        req.url layer_rest.gsub(geoserver_url, '')
        req.headers['Content-Type'] = 'text/xml'
        req.body = generic_style
      end
      puts update.status

    else
      puts " defaultStyle is already set as #{style}"
    end
  end
end
