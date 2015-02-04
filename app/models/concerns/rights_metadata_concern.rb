module RightsMetadataConcern
  extend Geoblacklight::SolrDocument

  def rights_metadata
    RightsMetadata.new(get(:stanford_rights_metadata_s))
  end
end
