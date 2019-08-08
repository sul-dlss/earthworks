# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
  include Geoblacklight::SolrDocument
  include GeomonitorConcern
  include RightsMetadataConcern
  include WmsRewriteConcern
  include CartodbConcern

  # self.unique_key = 'id'
  self.unique_key = 'layer_slug_s'
  
  self.field_semantics[:author] = :dc_creator_sm
  self.field_semantics[:title] = :dc_title_s
  self.field_semantics[:year] = :dct_temporal_sm

  def institution
    fetch(Settings.FIELDS.PROVENANCE)
  end

  def contact_email
    Settings.INSTITUTIONS.send(institution)&.email
  end

  def department
    Settings.INSTITUTIONS.send(institution)&.department
  end

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

end
