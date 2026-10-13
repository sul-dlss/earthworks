# frozen_string_literal: true

# Display an alert when an item is not georeferenced
module Document
  class GeoreferencedAlertComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    # Strict comparison: this method can return nil, if the gbl_georeferenced_b
    # field was absent. That's the case for most vector data, and we don't care
    # about showing an alert for those items.
    def render?
      @document.georeferenced? == false
    end
  end
end
