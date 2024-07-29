class SolrDocument
  include Blacklight::Solr::Document
  include Geoblacklight::SolrDocument
  # include GeomonitorConcern
  # https://github.com/geoblacklight/geo_monitor/issues/12
  include WmsRewriteConcern
  include LicenseConcern

  alias stanford? same_institution?

  def institution
    fetch(Settings.FIELDS.PROVIDER, '')
  end

  def contact_email
    Settings.INSTITUTIONS.send(institution)&.email
  end

  def department
    Settings.INSTITUTIONS.send(institution)&.department
  end

  def collection?
    fetch(Settings.FIELDS.RESOURCE_CLASS, []).include? 'Collections'
  end

  def mixed?
    fetch(Settings.FIELDS.RESOURCE_CLASS, []) == 'Other'
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

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
end
