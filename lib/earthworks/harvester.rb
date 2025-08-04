require 'geo_combine/harvester'

# A custom OpenGeoMetadata harvester that lets us limit repositories and transform metadata
module Earthworks
  class Harvester < GeoCombine::Harvester
    attr_reader :ogm_repos

    # Support passing in a configured list of repositories to harvest
    def initialize(ogm_repos: ENV.fetch('OGM_REPOS'), **)
      super(**)

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
    # in EarthWorks, especially for facets.
    def transform_record(record, path)
      # Transform provider name to a shorter, consistent value based on the repository
      if (transformed_provider = @ogm_repos.dig(record_repo(path), :provider))
        record.update({ 'schema_provider_s' => transformed_provider })
      end

      # Filter out themes that are not in the controlled vocabulary from OGM
      if (themes = record['dcat_theme_sm'])
        record.update({ 'dcat_theme_sm' => themes.select { |theme| Settings.ALLOWED_OGM_THEMES.include?(theme) } })
      end

      # Add a hierarchicalized version of the dates for the year facet
      if (years = record['gbl_indexYear_im'])
        record.update({ 'date_hierarchy_sm' => hierarchicalize_year_list(years) })
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

    # NOTE: this duplicates logic in searchworks_traject_indexer, see:
    # https://github.com/sul-dlss/searchworks_traject_indexer/pull/1521
    def hierarchicalize_year_list(years)
      centuries = Set.new
      decades = Set.new

      hierarchicalized_years = years.map do |year|
        century, decade = centimate_and_decimate(year)
        centuries << century
        decades << [century, decade].join(':')
        [century, decade, year].join(':')
      end

      centuries.to_a + decades.to_a + hierarchicalized_years
    end

    # NOTE: this duplicates logic in searchworks_traject_indexer, see:
    # https://github.com/sul-dlss/searchworks_traject_indexer/pull/1521
    def centimate_and_decimate(maybe_year)
      parsed_date = Date.new(maybe_year.to_i)
      [century_from_date(parsed_date), decade_from_date(parsed_date)]
    rescue Date::Error
      %w[unknown_century unknown_decade] # guess not
    end

    # NOTE: this duplicates logic in searchworks_traject_indexer, see:
    # https://github.com/sul-dlss/searchworks_traject_indexer/pull/1521
    def century_from_date(date)
      date.strftime('%C00-%C99')
    end

    # NOTE: this duplicates logic in searchworks_traject_indexer, see:
    # https://github.com/sul-dlss/searchworks_traject_indexer/pull/1521
    def decade_from_date(date)
      decade_prefix = (date.strftime('%Y').to_i / 10).to_s
      "#{decade_prefix}0-#{decade_prefix}9"
    end
  end
end
