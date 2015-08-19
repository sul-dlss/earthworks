module CartodbConcern
  extend Geoblacklight::SolrDocument

  def cartodb_reference
    return unless available?
    super
  end
end
