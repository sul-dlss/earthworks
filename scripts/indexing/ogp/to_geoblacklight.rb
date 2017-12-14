require 'geo_combine'
require 'active_support/core_ext/object/blank'

class ConvertOgp
  def initialize(fn)
    @input = JSON.parse(File.read(fn)).map do |ogp|
      GeoCombine::OGP.new(ogp.to_json) if ogp.present?
    end.compact
  end

  def save(fn)
    output = File.open(fn, 'w')
    converted = @input.collect do |ogp|
      begin
        ogp.to_geoblacklight
      rescue ArgumentError => e
        puts e.message
        nil
      end
    end.compact
    output << JSON.pretty_generate(converted)
    output.close
  end
end

# __MAIN__
convert = ConvertOgp.new('ogp.json')
convert.save('geoblacklight.json')
