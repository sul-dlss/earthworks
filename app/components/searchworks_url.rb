# frozen_string_literal: true

class SearchworksUrl < ViewComponent::Base
  attr_reader :document

  def initialize(document:, action:, **)
    @document = document
    super
  end

  def render?
    document.searchworks_url.present?
  end

  def key
    'searchworks_url'
  end
end
