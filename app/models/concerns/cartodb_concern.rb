module CartodbConcern
  extend Geoblacklight::SolrDocument

  def carto_reference
    return unless available?

    super
  end
end
