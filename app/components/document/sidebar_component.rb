# frozen_string_literal: true

# Render the sidebar on the show view
module Document
  class SidebarComponent < Geoblacklight::Document::SidebarComponent
    def components
      [
        Geoblacklight::LoginLinkComponent.new(document:),
        Geoblacklight::StaticMapComponent.new(document:),
        DownloadLinksComponent.new(document:)
      ]
    end
  end
end
