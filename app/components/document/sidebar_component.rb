# frozen_string_literal: true

# Render the sidebar on the show view
module Document
  class SidebarComponent < Geoblacklight::Document::SidebarComponent
    # Primary section of the sidebar that displays at the top
    def components
      [
        Geoblacklight::LoginLinkComponent.new(document:),
        Geoblacklight::StaticMapComponent.new(document:),
        DownloadLinksComponent.new(document:),
        Blacklight::Document::ShowToolsComponent.new(document:)
      ]
    end

    # Second section of the sidebar that displays below the main one
    def secondary_components
      [
        AlsoAvailableComponent.new(document:),
        'relations_container',
        Blacklight::Document::MoreLikeThisComponent.new(document:)
      ]
    end

    # Determine if there's actually anything to show by rendering everything
    def filter_components(components)
      components.map { |component| render component, document: }.compact_blank
    end

    # Rendered in between each component
    def separator
      content_tag :hr, nil, style: 'border-top: dotted 1px;'
    end
  end
end
