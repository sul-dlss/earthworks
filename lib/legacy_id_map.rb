# frozen_string_literal: true

class LegacyIdMap
  class << self
    def map
      @map ||= YAML.safe_load(File.read(path))
    end

    private

    def path
      Rails.root.join('config', 'legacy_id.map')
    end
  end
end
