# frozen_string_literal: true

class LegacyIdMap
  class << self
    def map
      @map ||= YAML.safe_load(File.read(path))
    end

    private

    def path
      File.join(Rails.root, 'config', 'legacy_id.map')
    end
  end
end
