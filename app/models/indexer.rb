##
# A simple class for sending updates to Solr
class Indexer
  def solr_update(data)
    Blacklight.default_index.connection.update(
      params: { commitWithin: commit_within, overwrite: true },
      data: data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def commit_within
    ENV.fetch('SOLR_COMMIT_WITHIN') { Settings.SOLR_COMMIT_WITHIN } || 5000
  end
end
