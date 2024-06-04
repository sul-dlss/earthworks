class SolrDocument
  include Blacklight::Solr::Document
  include Geoblacklight::SolrDocument
  # include GeomonitorConcern
  # https://github.com/geoblacklight/geo_monitor/issues/12
  include RightsMetadataConcern
  include WmsRewriteConcern

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
