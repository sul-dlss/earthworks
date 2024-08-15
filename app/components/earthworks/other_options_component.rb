module Earthworks
  # Display other options section in sidebar
  class OtherOptionsComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      @document = document
      super
    end
  end
end
