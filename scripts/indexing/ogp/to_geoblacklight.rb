require 'geo_combine'
require 'active_support/core_ext/object/blank'

class ConvertOgp
  def initialize(fn)
    @input = JSON.parse(File.read(fn)).filter_map do |ogp|
      GeoCombine::OGP.new(ogp.to_json) if ogp.present?
    end
  end

  def save(fn)
    output = File.open(fn, 'w')
    converted = @input.filter_map do |ogp|
      ogp.to_geoblacklight
    rescue ArgumentError => e
      puts e.message
      nil
    end
    output << JSON.pretty_generate(converted)
    output.close
  end
end

# __MAIN__
convert = ConvertOgp.new('ogp.json')
convert.save('geoblacklight.json')
