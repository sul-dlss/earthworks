# frozen_string_literal: true

class TranslationMap
  def initialize(name)
    @map = YAML.load_file(Rails.root.join('config', 'translation_maps', "#{name}.yml"))
  end

  def translate(values)
    Array(values).flat_map { |value| lookup(value) }.uniq
  end

  private

  # A key may map to a single value or to a list of values; always return a list
  def lookup(value)
    _key, translation = @map.find { |key, _translation| match?(key, value.to_s) }
    Array(translation)
  end

  def match?(key, value)
    return value.match?(Regexp.new(key[1..-2])) if key.start_with?('/') && key.end_with?('/')

    key == value
  end
end
