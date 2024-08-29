# frozen_string_literal: true

module Earthworks
  class ViewerContainerComponent < Geoblacklight::ViewerContainerComponent
    def initialize(document:)
      super
      @document = document
      @viewer_protocol = document.viewer_protocol
    end
  end
end
