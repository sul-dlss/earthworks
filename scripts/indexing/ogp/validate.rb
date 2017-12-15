# frozen_string_literal: true

#
# Usage: validate_ogp [output.json]
#
#  Requires data/*.json as input and output to valid.json
#
require 'json'
require 'uri'
require 'date'

class ValidateOgp
  def initialize(fn)
    @wms_servers = {}
    @output = File.open(fn, 'wb')
    @output.write "[\n"
    yield self
    close
  end

  def validate_file(fn)
    stats = { accepted: 0, rejected: 0 }
    puts "Validating #{fn}"
    json = JSON.parse(File.read(fn))
    json['response']['docs'].each do |doc| # contains JSON Solr query results
      begin
        validate(doc)
        stats[:accepted] += 1
      rescue ArgumentError => e
        puts e
        stats[:rejected] += 1
      end
    end
    stats
  end

  def validate(layer)
    id = layer['LayerId']

    %w[LayerId Name Institution Access MinX MinY MaxX MaxY LayerDisplayName].each do |k|
      if layer[k].nil? || layer[k].to_s.empty?
        raise ArgumentError, "ERROR: #{id} missing #{k}"
      end
    end

    k = 'LayerId'
    layer[k] = layer[k].first if layer[k].is_a? Array
    raise ArgumentError, "ERROR: #{k} is not a String: #{layer[k]}" unless layer[k].is_a? String

    %w[MinX MaxX].each do |lon|
      raise ArgumentError, "ERROR: #{id}: Invalid longitude value: #{layer[lon]}" unless lon?(layer[lon])
    end

    %w[MinY MaxY].each do |lat|
      raise ArgumentError, "ERROR: #{id} Invalid latitude value: #{layer[lat]}" unless lat?(layer[lat])
    end

    if layer['MinX'].to_s.to_f > layer['MaxX'].to_s.to_f
      raise ArgumentError, "ERROR: #{id} has MinX > MaxX"
    end

    if layer['MinY'].to_s.to_f > layer['MaxY'].to_s.to_f
      raise ArgumentError, "ERROR: #{id} has MinY > MaxY"
    end

    k = 'Institution'
    layer[k] = 'Columbia' if layer[k] == 'Columbia University'
    if ([layer[k]] & %w[Berkeley Harvard MIT MassGIS Stanford Tufts UCLA Minnesota Columbia]).empty?
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'DataType'
    layer[k] = 'Paper Map' if layer[k] == 'Paper'
    if ([layer[k]] & %w[Line Paper\ Map Point Polygon Raster CD-ROM DVD-ROM]).empty?
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'Access'
    if ([layer[k]] & %w[Public Restricted]).empty?
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'WorkspaceName'
    layer[k] = layer['Institution'] if layer[k].nil?

    k = 'Availability'
    case layer[k].downcase
    when 'online'
      layer[k] = 'Online'
    when 'offline'
      layer[k] = 'Offline'
    end
    if ([layer[k]] & %w[Online Offline]).empty?
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'Location'
    layer[k] = validate_location(id, layer[k])
    if layer[k].nil?
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'GeoReferenced'
    unless layer[k].nil? || (layer[k] == true)
      puts "WARNING: #{id} has boundingbox but claims it is not georeferenced"
      # layer[k] = true
    end

    k = 'Area'
    unless layer[k].to_i >= 0
      raise ArgumentError, "ERROR: #{id} has unsupported #{k}: #{layer[k]}"
    end

    k = 'ContentDate'
    if layer[k].nil? || layer[k].to_s.strip.empty?
      layer.delete(k)
    else
      dt = Date.rfc3339(layer[k])
      if (dt.year <= 1) || (dt.year > 2100)
        puts "WARNING: #{id} has invalid #{k}: #{layer[k]}: #{dt}"
        layer.delete(k)
      end
    end

    # k = 'FgdcText'
    # unless layer[k].nil? or layer[k].empty?
    #   layer[k] = ''
    # end

    @output.write JSON.pretty_generate(layer)
    @output.write "\n,\n"
  end

  def close
    @output.write "\n {} \n]\n"
    @output.close
    puts(wms_servers: @wms_servers)
  end

  private

  def validate_location(id, location)
    begin
      x = JSON.parse(location)
    rescue JSON::ParserError => e
      x = JSON.parse("{ #{location} }") # wrap in dictionary
    end

    unless x['externalDownload'].nil?
      x['download'] = x['externalDownload']
      x.delete('externalDownload')
    end
    unless x['libRecord'].nil?
      x['url'] = x['libRecord']
      x.delete('libRecord')
    end
    if x['download'].nil? && x['wms'].nil? && (x['wcs'].nil? && x['wfs'].nil?) && x['url'].nil?
      puts "WARNING: #{id}: Missing Download or WMS or WCS/WFS or URL: #{x}"
      return {}.to_json
    end

    %w[download wms wcs wfs url].each do |protocol|
      begin
        unless x[protocol].nil?
          if x[protocol].is_a? String
            if x[protocol].empty? || x[protocol] == 'None available'
              x[protocol] = nil
              next
            else
              x[protocol] = [x[protocol]]
            end
          end

          unless x[protocol].is_a? Array
            raise ArgumentError, "ERROR: #{id}: Unknown #{protocol} value: #{x}"
          end

          x[protocol].each do |url|
            uri = URI.parse(url)
            raise ArgumentError, "ERROR: #{id}: Invalid URL: #{uri}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) || uri.is_a?(URI::FTP)
          end

          # convert from Array to String
          x[protocol] = x[protocol].first if x[protocol].is_a? Array

          @wms_servers[x[protocol]] = true if protocol == 'wms'
        end
      rescue URI::InvalidURIError => e
        raise ArgumentError, "ERROR: #{id}: Invalid URL parsing: #{x}"
      end
    end
    x.to_json
  end

  def lon?(lon)
    (lon >= -180) && (lon <= 180)
  end

  def lat?(lat)
    (lat >= -90) && (lat <= 90)
  end
end

# __MAIN__
ValidateOgp.new(ARGV[0].nil? ? 'ogp.json' : ARGV[0]) do |ogp|
  stats = { accepted: 0, rejected: 0 }
  Dir.glob('data/*.json') do |fn|
    s = ogp.validate_file(fn)
    stats[:accepted] += s[:accepted]
    stats[:rejected] += s[:rejected]
  end
  puts(statistics: stats)
end
