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
        datasets = titles.select { |s| s['payload'] == 'Datasets' }
        maps = titles.select { |s| s['payload'] == 'Maps' }

        { locations: locations, datasets: datasets, maps: maps }
      end
    end
  end
end
