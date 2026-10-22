# frozen_string_literal: true

class RecentlyUpdatedListComponent < ViewComponent::Base
  attr_reader :response, :term

  delegate :documents, :total, to: :response

  # @param response [Blacklight::Solr::Response] recently updated items of the given type
  # @param term [String] the value of the resource class facet the items belong to
  def initialize(response:, term:)
    super()
    @response = response
    @term = term
  end

  def type
    term.downcase
  end

  def search_url
    fields = Geoblacklight.configuration.fields
    helpers.search_catalog_path("f[#{fields.resource_class}][]": term, sort: "#{fields.modified} desc")
  end

  def heading_id
    "recently-updated-#{type}"
  end
end
