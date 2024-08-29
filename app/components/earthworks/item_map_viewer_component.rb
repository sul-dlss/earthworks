# frozen_string_literal: true

module Earthworks
  class ItemMapViewerComponent < Geoblacklight::ItemMapViewerComponent
    def initialize(document:)
      super
      @document = document
    end

    private

    # Generate the viewer HTML for IIIF content
    def iiif_tag
      puts 'IIIF TAG'

      tag.div(nil,
              id: 'mirador',
              class: 'viewer',
              data: {
                controller: 'mirador',
                mirador_target: 'container'
                # 'clover-viewer-protocol-value': protocol,
                # 'clover-viewer-url-value': @document.viewer_endpoint
              })
    end
  end
end
