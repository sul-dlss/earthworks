module EarthworksGeoblacklightHelper
  include GeoblacklightHelper

  def document_available?
    (@document.public? && @document.available?) ||
      (@document.same_institution? && user_signed_in? && @document.available?)
  end

  # Override to render multi-valued description as individual paragraphs
  def render_value_as_truncate_abstract(args)
    tag.div class: 'truncate-abstract' do
      Array(args[:value]).flatten.collect { |v| concat tag.p(v) }
    end
  end

  # Try to render a human-readable license description, or fall back to the URI
  def render_license(args)
    tag.span @document.license.description
  rescue License::UnknownLicenseError
    tag.span args[:value]
  end

  # Use Mirador as the IIIF manifest viewer
  def iiif_manifest_viewer
    tag.div(nil, id: 'mirador', data: { 'manifest-url' => @document.viewer_endpoint })
  end
end
