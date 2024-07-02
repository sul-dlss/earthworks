# frozen_string_literal: true

# Custom handling for license URIs
module LicenseConcern
  extend Geoblacklight::SolrDocument

  # Use the first URI in the license field to create a License object
  def license
    license_uris = fetch(:dct_license_sm, [])
    License.new(url: license_uris.first)
  end
end
