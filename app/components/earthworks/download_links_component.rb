# frozen_string_literal: true

module Earthworks
  # Display expandable file download links in sidebar
  class DownloadLinksComponent < Geoblacklight::DownloadLinksComponent
    def download_link_file(label, id, url)
      link_to(
        label,
        url,
        'contentUrl' => url,
        :class => 'btn btn-primary',
        :data => {
          download: 'trigger',
          download_type: 'direct',
          download_id: id
        }
      )
    end

    def download_link_hgl(text, document)
      link_to(
        text,
        download_hgl_path(id: document),
        class: 'btn btn-primary',
        data: {
          blacklight_modal: 'trigger',
          download: 'trigger',
          download_type: 'harvard-hgl',
          download_id: document.id
        }
      )
    end

    # Generates the link markup for the IIIF JPEG download
    # @return [String]
    def download_link_iiif
      link_to(
        download_text('JPG'),
        iiif_jpg_url,
        'contentUrl' => iiif_jpg_url,
        :class => 'btn btn-primary',
        :data => {
          download: 'trigger'
        }
      )
    end
  end
end
