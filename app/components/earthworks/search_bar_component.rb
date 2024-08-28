# frozen_string_literal: true

module Earthworks
  class SearchBarComponent < Blacklight::SearchBarComponent
    def search_button
      render Earthworks::SearchButtonComponent.new(id: "#{@prefix}search", text: scoped_t('submit'))
    end
  end
end
