require 'faraday'
require 'nokogiri'

##
# This script updates the default layer styling for vector data that we
# host. Unfortunately there is no global way to set this, so it has to happen
# on a per layer basis.

geoserver_url = ENV.fetch('GEOSERVER_URL', nil)

raise('GEOSERVER_URL not provided') unless geoserver_url
raise('GEOSERVER_USER not provided') unless ENV['GEOSERVER_USER']
raise('GEOSERVER_PASS not provided') unless ENV['GEOSERVER_PASS']

solr_data = Faraday.get('https://sul-solr-a.stanford.edu/solr/kurma-earthworks-v1-prod/select?fl=layer_slug_s,layer_geom_type_s&q=dct_provenance_s:Stanford&fq=-layer_geom_type_s:Raster&fq=-layer_geom_type_s:Image&rows=20000&wt=csv&csv.header=false')
expected_styles = solr_data.body.split("\n").each_with_object({}) do |row, hash|
  slug, geom = row.split(',', 2)
  _, druid = slug.split('-', 2)

  hash[druid] = geom.downcase
end

puts "Updating WMS default style for all vector layers on #{geoserver_url}"

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
  druid = name.strip.sub('druid:', '')

  layer_rest = layer.xpath('atom:link', atom: 'http://www.w3.org/2005/Atom').attribute('href').to_s

  layer_response = conn.get do |req|
    req.url layer_rest.gsub(geoserver_url, '')
  end.body
  parsed_response = Nokogiri::XML(layer_response)
  next unless parsed_response.xpath('//type').text == 'VECTOR'

  print "#{name} is a vector; "
  style = parsed_response.xpath('//defaultStyle').text.strip

  expected_style = expected_styles[druid] || 'generic'

  if style != expected_style && (style.empty? || style == 'generic')
    print " setting style (current: '#{style}') to '#{expected_styles[druid]}'"
    generic_style =
      <<~XML
        <layer>
          <defaultStyle>
            <name>#{expected_styles[druid]}</name>
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
