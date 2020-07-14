module ApplicationHelper
  def document_unavailable_options(document)
    options = []
    options.push 'download' unless document.direct_download || document.download_types.present? || document.iiif_download.present? || document.oembed.present? || document.collection? || document.mixed?
    options.push('preview', 'download') unless document_available? || document.stanford? || document.restricted?
    options
  end
end
