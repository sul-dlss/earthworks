# frozen_string_literal: true

# Render the sidebar on the show view
module Document
  class SidebarComponent < Geoblacklight::Document::SidebarComponent
    def components
      [
        Geoblacklight::LoginLinkComponent.new(document: document),
        Geoblacklight::StaticMapComponent.new(document: document),
        DownloadLinksComponent.new(document: document),
        AlsoAvailableComponent.new(document: document)
      ]
    end
  end
end
