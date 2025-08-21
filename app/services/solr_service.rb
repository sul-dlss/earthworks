# Update or delete records from the Solr index
class SolrService
  # Delete a record from the index by ID
  # TODO: https://github.com/sul-dlss/earthworks/issues/1536
  def self.delete_by_id(record_id)
    Rails.logger.info "Deleting Solr document: #{record_id}"
  end

  # Update a record in the index
  # TODO: https://github.com/sul-dlss/earthworks/issues/1536
  def self.update(record)
    Rails.logger.info "Updating Solr document: #{record.druid}"
  end
end
