# frozen_string_literal: true

# Render the sidebar on the show view
module Document
  class SidebarComponent < Geoblacklight::Document::SidebarComponent
    # Primary section of the sidebar that displays at the top
    def components
      [
        Geoblacklight::LoginLinkComponent.new(document:),
        StaticMapComponent.new(document:),
        DownloadLinksComponent.new(document:),
        ShowToolsComponent.new(document:),
        AccessComponent.new(document:),
        'relations_container',
        Blacklight::Document::MoreLikeThisComponent.new(document:),
        AlsoAvailableComponent.new(document:)
      ]
    end
  end
end
