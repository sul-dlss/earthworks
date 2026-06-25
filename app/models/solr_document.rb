class SolrDocument
  include Blacklight::Solr::Document
  include Geoblacklight::SolrDocument

  alias stanford? same_institution?

  attribute :rights, :array, :dct_rights_sm
  attribute :rights_holder, :array, :dct_rightsHolder_sm
  attribute :license_uris, :array, :dct_license_sm

  def dataset?
    fetch(Geoblacklight.configuration.fields.resource_class, []).include?('Datasets')
  end

  def external_links
    fetch(Geoblacklight.configuration.fields.identifier, []).filter { |identifier| identifier.start_with?('http') }
  end

  # Examine the list of references (in dct_references_s) to find a "schema.org/relatedLink"
  #  This is going to be the searchworks url if present.
  #  See https://github.com/sul-dlss/searchworks_traject_indexer/pull/1490
  #  References are retrieved from the SolrDocument as an array of Geoblacklight::Reference
  #  where the "reference" attribute is an array of two elements, the first being the type and the second being the url
  def searchworks_url
    related_link = references.refs.find { |ref| ref.reference[0] == 'https://schema.org/relatedLink' }
    related_link.present? ? related_link.reference[1] : nil
  end

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Check to see if view is an image
  # Used for georeferencing message
  def image?
    file_format&.include?('JPEG')
  end
end
