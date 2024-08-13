# frozen_string_literal: true

module Earthworks
  class SearchResultComponent < Geoblacklight::SearchResultComponent
    def classes
      [
        @classes,
        helpers.render_document_class(@document),
        'document',
        'pt-0',
        'mt-0',
        ("document-position-#{@counter}" if @counter)
      ].compact.flatten
    end
  end
end
