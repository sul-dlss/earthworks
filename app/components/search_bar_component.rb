# frozen_string_literal: true

class SearchBarComponent < Blacklight::SearchBarComponent
  def search_button
    render SearchButtonComponent.new(id: "#{@prefix}search", text: scoped_t('submit'))
  end
end
