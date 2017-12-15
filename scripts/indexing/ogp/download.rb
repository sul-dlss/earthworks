require 'open-uri'

class DownloadOgp
  URL = {
    'tufts' => 'http://geodata.tufts.edu/solr/select',
    'mit' => 'http://arrowsmith.mit.edu/solr/select',
    'berkeley' => 'http://geodata.lib.berkeley.edu/solr4/select',
    'harvard' => 'http://pelham.lib.harvard.edu:8080/opengeoportal/solr/select',
    'ucla' => 'http://vizsla.oit.ucla.edu:8080/solr/select',
    'columbia' => 'http://culspatial.cul.columbia.edu/solr/select',
    'minnesota' => 'http://ec2-54-87-229-228.compute-1.amazonaws.com:8080/solr/collection1/select'
  }

  FIELDS = %w{
    Abstract
    Access
    Area
    Availability
    CenterX
    CenterY
    ContentDate
    DataType
    ExternalLayerId
    FgdcText
    GeoReferenced
    HalfHeight
    HalfWidth
    Institution
    LayerDisplayName
    LayerId
    Location
    MaxX
    MaxY
    MinX
    MinY
    Name
    PlaceKeywords
    Publisher
    SrsProjectionCode
    ThemeKeywords
    WorkspaceName
  }.join(',')

  def download(src, i, n, w=50)
    start = 0
    i = src if i.nil?
    while start < n do
      fetch(src, i, start, w)
      start += w
    end
  end

  # fetch a set of Solr records from the src provider about the target institution
  #
  # @param [String] src The source provider of the Solr records
  # @param [String] target the target institution
  # @param [Integer] start
  # @param [Integer] rows
  def fetch(src, target, start, rows, datadir = 'data')
    fn = File.join(datadir, "#{src.downcase}_#{target.downcase}_#{sprintf('%05i', start)}_#{rows}.json")
    unless File.exist?(fn)
      raise "Unknown URL for #{src}" unless URL.include?(src.downcase)
      puts "Downloading #{target} #{start} to #{start+rows}"
      url = "#{URL[src.downcase]}?" + URI::encode_www_form(
                  'q' => '*:*',
                  'fq' => "Institution:#{target}",
                  'start' => start,
                  'rows' => rows,
                  'wt' => 'json',
                  'indent' => 'on',
                  'fl' => FIELDS
                  )
      puts "    #{url}" if $DEBUG
      open(url) do |res|
        File.open(fn, 'wb') do |f|
          f.write(res.read())
        end
      end
    else
      puts "Using cache for #{target} #{start} to #{start+rows}"
    end
  end
end

# __MAIN__
ogp = DownloadOgp.new
# ogp.download('Berkeley', 'Berkeley', 450)
ogp.download('Tufts', 'MassGIS', 600)
ogp.download('Tufts', 'Tufts', 3100)
ogp.download('Harvard', 'Harvard', 11000)
ogp.download('MIT', 'MIT', 11000)
# ogp.download('UCLA', 'UCLA', 200)
# ogp.download('Columbia', 'Columbia', 3600)
# ogp.download('Minnesota', 'Minnesota', 2300)
