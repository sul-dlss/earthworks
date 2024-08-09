# frozen_string_literal: true

module Earthworks
  # Render the sidebar on the show view
  module Document
    class SidebarComponent < Geoblacklight::Document::SidebarComponent
      def components
        [
          Geoblacklight::LoginLinkComponent.new(document: document),
          Geoblacklight::StaticMapComponent.new(document: document),
          Earthworks::DownloadLinksComponent.new(document: document)
        ]
      end
    end
  end
end
