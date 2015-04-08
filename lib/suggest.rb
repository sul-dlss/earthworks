module Earthworks
  module Suggest
    extend ActiveSupport::Concern
    include Suggest::SearchHelper

    ##
    # Get suggestion results from the Solr index
    def index
      @response = get_suggestions params
      respond_to do |format|
        format.json do
          render json: @response.suggestions
        end
      end
    end
  end
end
