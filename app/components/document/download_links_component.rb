# frozen_string_literal: true

module Document
  class DownloadLinksComponent < Geoblacklight::Document::DownloadLinksComponent
    def child_component
      Document::DownloadLinkComponent
    end
  end
end
