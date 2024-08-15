module Earthworks
  # Display other options section in sidebar
  class CodeSnippetLinkComponent < ViewComponent::Base
    def initialize(id)
      @id = id
      super
    end
  end
end
