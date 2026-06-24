module Document
  class AccessComponent < ViewComponent::Base
    def initialize(document:)
      super()
      @document = document
    end

    attr_reader :document

    delegate :rights, :rights_holder, :license_uris, :external_links, to: :document

    def render?
      rights.present? || rights_holder.present? || license_uris.present? || external_links.present?
    end

    def render_details_links
      tag.ul class: 'list-unstyled' do
        external_links.collect { |url| concat tag.li(link_to(url, url)) }
      end
    end

    # Try to render a human-readable license description, or fall back to the URI
    def render_license
      tag.span license.description
    rescue License::UnknownLicenseError
      tag.span license_uris.first
    end

    def license
      return if license_uris.empty?

      License.new(url: license_uris.first)
    end
  end
end
