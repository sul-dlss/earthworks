# frozen_string_literal: true

# Display also available as links in sidebar
class AlsoAvailableComponent < ViewComponent::Base
  attr_reader :document

  def initialize(document:)
    @document = document
    super()
  end

  # a list of all the available other urls for the document
  def also_available_links
    { SearchWorks: document.searchworks_url }.compact_blank
  end

  def render?
    also_available_links.present?
  end
end
