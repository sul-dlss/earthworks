module Earthworks
  module Suggest
    class Response
      attr_reader :response, :request_params

      ##
      # Creates a suggest response
      # @param [RSolr::HashWithResponse] response
      # @param [Hash] request_params
      def initialize(response, request_params)
        @response = response
        @request_params = request_params
      end

      ##
      # Trys the suggestor response to return suggestions if they are
      # present
      # @return [Array]
      def suggestions
        response.try(:[], 'suggest').try(:[], 'mySuggester').try(:[], request_params[:q]).try(:[], 'suggestions') || []
      end
    end
  end
end
