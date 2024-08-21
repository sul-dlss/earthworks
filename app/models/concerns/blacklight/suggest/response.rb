# frozen_string_literal: true

module Blacklight
  module Suggest
    class Response
      attr_reader :response, :request_params, :suggest_path, :suggester_name

      ##
      # Creates a suggest response
      # @param [RSolr::HashWithResponse] response
      # @param [Hash] request_params
      # @param [String] suggest_path
      # @param [String] suggester_name
      def initialize(response, request_params, suggest_path, suggester_name)
        @response = response
        @request_params = request_params
        @suggest_path = suggest_path
        @suggester_name = suggester_name
      end

      ##
      # Trys the suggester response to return suggestions if they are
      # present
      # @return [Array]
      def suggestions
        locations = response.dig(suggest_path, 'spatialSuggester', request_params[:q], 'suggestions')
        # unpack the titles into datasets and maps using their payload value
        titles = response.dig(suggest_path, 'titleSuggester', request_params[:q], 'suggestions')
        themes = response.dig(suggest_path, 'themeSuggester', request_params[:q], 'suggestions')
        categorized_titles = categorize_titles(titles)

        { locations: locations, datasets: categorized_titles['datasets'], maps: categorized_titles['maps'],
          themes: themes, full: response }
      end

      def categorize_titles(titles)
        datasets = []
        maps = []
        titles.each do |title|
          payload = title['payload']
          payload_json = JSON.parse(payload) unless payload.empty?

          id = payload_json['id']
          classes = payload_json['class']
          types = payload_json['type']
          title['id'] = id
          title['classes'] = classes
          title['types'] = types
          datasets.push(title) if classes.include?('Datasets')
          maps.push(title) if classes.include?('Maps')
        end
        { datasets: datasets, maps: maps }.with_indifferent_access
      end
    end
  end
end
