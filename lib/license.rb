# frozen_string_literal: true

# This is the license entity used for translating a license URL into text
# that is rendered on an item's show page
class License
  attr_reader :description, :uri

  # Raised when the license provided is not valid
  class UnknownLicenseError < StandardError; end

  def self.licenses
    @licenses ||= Rails.application.config_for(:licenses, env: 'production').stringify_keys
  end

  def initialize(url:)
    raise UnknownLicenseError unless License.licenses.key?(url)

    attrs = License.licenses.fetch(url)
    @uri = url
    @description = attrs.fetch(:description)
  end
end
