# frozen_string_literal: true

class CitationModalComponent < ViewComponent::Base
  def initialize(documents:)
    @documents = documents
    super()
  end
end
