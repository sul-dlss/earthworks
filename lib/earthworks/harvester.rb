require 'geo_combine/harvester'

# A custom OpenGeoMetadata harvester that lets us limit repositories and transform metadata
module Earthworks
  class Harvester < GeoCombine::Harvester
    attr_reader :ogm_repos

    # Support passing in a configured list of repositories to harvest
    def initialize(ogm_repos: ENV.fetch('OGM_REPOS'), **kwargs)
      super(**kwargs)

      @ogm_repos = ogm_repos.to_h.transform_keys(&:to_s)
    end

    # Support skipping and transforming arbitrary records prior to indexing
    def docs_to_index
      return to_enum(:docs_to_index) unless block_given?

      super do |record, path|
        yield transform_record(record, path), path unless skip_record?(record, path)
      end
    end

    private

    # Some records have placeholder data or are otherwise problematic, but we
    # can't denylist them at the institution/repository level.
    def skip_record?(record, path)
      # Skip PolicyMap records in shared-repository; they have placeholder data
      #   See https://github.com/OpenGeoMetadata/shared-repository/tree/master/gbl-policymap
      # Skip other institutions' restricted records (need not check instituion here: Stanford records already filtered)
      #   See https://github.com/sul-dlss/earthworks/issues/1089
      (record_repo(path) == 'shared-repository' && path.include?('gbl-policymap')) || restricted?(record)
    end

    def restricted?(record)
      # no need to check dc_rights_s, that was the field name under schema 1.0, but we don't expect
      # to switch back from Aardvark
      record.fetch('dct_accessRights_s', '').downcase == 'restricted'
    end

    # We transform some records in order to get more consistent metadata display
    # in Earthworks, especially for facets.
    def transform_record(record, path)
      # Transform provider name to a shorter, consistent value based on the repository
      if (transformed_provider = @ogm_repos.dig(record_repo(path), :provider))
        record.update({ 'schema_provider_s' => transformed_provider })
      end

      record
    end

    # Get the name of the repository the record came from
    def record_repo(path)
      path.split(@ogm_path).last.split('/')[1]
    end

    # Only harvest configured repositories, if configuration was provided
    def repositories
      @repositories ||= @ogm_repos ? super.compact.select { |repo| @ogm_repos.key?(repo) } : super
    end
  end
end
