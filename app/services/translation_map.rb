# frozen_string_literal: nil

class TranslationMap
  def initialize(name)
    @map = YAML.load_file(Rails.root.join('config', 'translation_maps', "#{name}.yml"))
  end

  def translate(values)
    Array(values).filter_map do |value|
      match = nil
      @map.each do |k, v|
        if k.start_with?('/') && k.end_with?('/')
          regex = Regexp.new(k[1..-2])
          if value.to_s.match?(regex)
            match = v
            break
          end
        elsif k == value.to_s
          match = v
          break
        end
      end
      match
    end.uniq
  end
end
