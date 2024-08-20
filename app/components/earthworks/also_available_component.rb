# frozen_string_literal: true

module Earthworks
  # Display also available as links in sidebar
  class AlsoAvailableComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:, **)
      @document = document
      super
    end

    def render?
      document.also_available_links.present?
    end
  end
end
