require 'time'
require 'json'
require 'nokogiri'
require_relative 'country_bboxes'

module Earthworks
  module Hdx
    class Mapper
      # Map a single HDX dataset hash to OGM Aardvark schema
      # @param dataset [Hash] raw dataset JSON from HDX API
      # @return [Hash] mapped OGM Aardvark JSON
      def self.map(dataset)
        new(dataset).map
      end

      def initialize(dataset)
        @dataset = dataset || {}
      end

      # Perform the metadata mapping to OGM Aardvark
      # @return [Hash]
      def map
        # Required properties
        mapped = {
          'id' => "hdx-#{dataset_id}",
          'gbl_mdVersion_s' => 'Aardvark',
          'gbl_mdModified_dt' => format_modified_date(dataset['metadata_modified']),
          'dct_title_s' => dataset['title'] || 'Untitled HDX Dataset',
          'dct_accessRights_s' => dataset['private'] ? 'Restricted' : 'Public',
          'gbl_resourceClass_sm' => ['Datasets']
        }

        # Optional recommended properties
        mapped['dct_description_sm'] = [sanitize_description(dataset['notes'])] if dataset['notes'].present?
        mapped['dct_language_sm'] = ['eng']
        mapped['schema_provider_s'] = 'Humanitarian Data Exchange'

        publisher = dataset['dataset_source'] || dataset.dig('organization', 'title')
        mapped['dct_publisher_sm'] = [publisher] if publisher.present?

        # Keywords / Tags / Subjects
        tags = (dataset['tags'] || []).map { |t| t['display_name'] || t['name'] }.compact.uniq
        mapped['dcat_keyword_sm'] = tags if tags.any?
        mapped['dct_subject_sm'] = tags if tags.any?

        # Spatial Coverage
        countries = (dataset['groups'] || []).map { |g| g['title'] || g['display_name'] }.compact.uniq
        mapped['dct_spatial_sm'] = countries if countries.any?

        # Spatial Extents (Geometry / Bounding Box)
        bbox = combined_bbox(countries)
        if bbox
          envelope = format_envelope(bbox)
          mapped['locn_geometry'] = envelope
          mapped['dcat_bbox'] = envelope
        end

        # Temporal Coverage & Index Year
        years = parse_years(dataset['dataset_date'])
        if years.any?
          mapped['dct_temporal_sm'] = format_temporal(years)
          mapped['gbl_indexYear_im'] = format_index_years(years)
        end

        # Technical Metadata (Format & References)
        format = determine_format
        mapped['dct_format_s'] = format if format

        refs = build_references
        mapped['dct_references_s'] = refs.to_json if refs.any?

        mapped
      end

      private

      # Extract UUID/id from dataset
      def dataset_id
        @dataset['id'] || @dataset['name'] || SecureRandom.uuid
      end

      # Strip HTML tags and clean up whitespace
      def sanitize_description(notes)
        return nil if notes.blank?
        # Use Nokogiri to strip any HTML markup
        Nokogiri::HTML.fragment(notes).text.strip.gsub(/\s+/, ' ')
      end

      # Format metadata modification date to UTC ISO8601
      def format_modified_date(date_str)
        return Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ') if date_str.blank?
        Time.parse(date_str).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      rescue StandardError
        Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end

      # Combine bounding boxes of multiple countries into a single envelope
      def combined_bbox(countries)
        return nil if countries.nil? || countries.empty?

        min_lon = nil
        min_lat = nil
        max_lon = nil
        max_lat = nil

        countries.each do |country|
          box = Earthworks::Hdx::CountryBboxes.bbox_for(country)
          next unless box # Skip if country coordinates are not found

          # box is [min_lon, min_lat, max_lon, max_lat]
          min_lon = min_lon ? [min_lon, box[0]].min : box[0]
          min_lat = min_lat ? [min_lat, box[1]].min : box[1]
          max_lon = max_lon ? [max_lon, box[2]].max : box[2]
          max_lat = max_lat ? [max_lat, box[3]].max : box[3]
        end

        return nil unless min_lon && min_lat && max_lon && max_lat

        [min_lon, min_lat, max_lon, max_lat]
      end

      # Format [min_lon, min_lat, max_lon, max_lat] to Solr ENVELOPE format
      def format_envelope(box)
        return nil if box.nil?
        "ENVELOPE(#{box[0]}, #{box[2]}, #{box[3]}, #{box[1]})"
      end

      # Parse dataset date range to locate all four-digit years
      def parse_years(date_str)
        return [] if date_str.blank?
        date_str.scan(/\b\d{4}\b/).map(&:to_i).uniq.sort
      end

      # Format years array into temporal string array (e.g. ["2020-2024"] or ["2015"])
      def format_temporal(years)
        return [] if years.empty?
        if years.size == 1
          [years.first.to_s]
        else
          ["#{years.first}-#{years.last}"]
        end
      end

      # Generate array of years for index faceting (e.g. from 2015 to 2018)
      def format_index_years(years)
        return [] if years.empty?
        if years.size == 1
          [years.first]
        else
          # limit date expansion range to prevent indexing massive number of years
          # if the metadata date is faulty or covers 1000s of years
          start_year = [years.first, 1500].max
          end_year = [years.last, Time.now.year + 10].min
          (start_year..end_year).to_a
        end
      end

      # Identify the format representing the dataset
      def determine_format
        resources = @dataset['resources'] || []
        return nil if resources.empty?

        formats = resources.map { |r| r['format'] }.compact.reject(&:empty?)
        # Prefer known spatial formats
        spatial_formats = %w[GeoTIFF Shapefile GeoJSON KML KMZ GML GPX CSV]
        spatial_format = formats.find { |f| spatial_formats.include?(f) }

        spatial_format || formats.first
      end

      # Build reference links for Aardvark dct_references_s
      def build_references
        refs = {}

        # Main landing page url
        name_or_id = @dataset['name'] || @dataset['id']
        if name_or_id.present?
          refs['http://schema.org/url'] = "https://data.humdata.org/dataset/#{name_or_id}"
        end

        # Look for the primary download link
        resources = @dataset['resources'] || []
        spatial_formats = %w[GeoTIFF Shapefile GeoJSON KML KMZ GML GPX]
        spatial_resource = resources.find { |r| spatial_formats.include?(r['format']) } || resources.first

        if spatial_resource && spatial_resource['download_url'].present?
          refs['http://schema.org/downloadUrl'] = spatial_resource['download_url']
        end

        refs
      end
    end
  end
end
