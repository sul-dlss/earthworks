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
        AlsoAvailableComponent.new(document:),
        'relations_container',
        Blacklight::Document::MoreLikeThisComponent.new(document:)
      ]
    end

    # Determine if there's actually anything to show by rendering everything
    def filtered_components
      components.map { |component| render component, document: }.compact_blank
    end
  end
end
