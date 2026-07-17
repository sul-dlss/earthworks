# Update or delete records from the Solr index
class SolrService
  # Delete a record from the index by ID
  def self.delete_by_id(druid)
    record_id = "stanford-#{druid}"
    Rails.logger.info "Deleting Solr document: #{record_id}"
    connection.delete_by_id(record_id, params: { commitWithin: Settings.solr_commit_within })
  end

  # Delete records from the index by ID
  def self.delete_by_ids(druids)
    record_ids = druids.map { |druid| "stanford-#{druid}" }
    Rails.logger.info "Deleting #{record_ids.size} Solr documents"
    connection.delete_by_id(record_ids, params: { commitWithin: Settings.solr_commit_within })
  end

  # Update a record in the index
  def self.update(record)
    Rails.logger.info "Updating Solr document: stanford-#{record.druid}"
    doc = CocinaToSolrMapper.map(record)
    connection.update(
      params: { commitWithin: Settings.solr_commit_within, overwrite: true },
      data: [doc].to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.connection
    Blacklight.default_index.connection
  end
end
