module RightsMetadataConcern
  extend Geoblacklight::SolrDocument

  def rights_metadata
    RightsMetadata.new(fetch(:stanford_rights_metadata_s, {}))
  end
end
