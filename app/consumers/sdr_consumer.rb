# Harvest items published from SDR for indexing
class SdrConsumer < Racecar::Consumer
  RECORD_NOT_FETCHED = Object.new.freeze
  private_constant :RECORD_NOT_FETCHED

  subscribes_to Settings.indexer_topic
  self.group_id = Settings.indexer_group

  def initialize(
    target: Settings.purl_fetcher.target.downcase,
    skip_catkey: Settings.purl_fetcher.skip_catkey,
    cocina_service: CocinaService,
    solr_service: SolrService
  )
    super()
    @target = target
    @skip_catkey = skip_catkey
    @cocina_service = cocina_service
    @solr_service = solr_service
  end

  # Process a batch of messages from a single Kafka partition
  def process_batch(messages)
    pending_deletes = []

    messages.each do |message|
      prepare(message)
      if delete?
        pending_deletes << @druid
      else
        process_deletes(pending_deletes)
        pending_deletes.clear
        process_update
      end
    end

    process_deletes(pending_deletes)
  rescue StandardError => e
    Honeybadger.notify(e)
    raise e
  end

  private

  # Set the state for a single message; key is the druid
  def prepare(message)
    @druid = message.key.delete_prefix('druid:')
    @change = message.value.present? ? JSON.parse(message.value) : nil
    @record = RECORD_NOT_FETCHED
  end

  # Determine if the item should be removed from the index
  def delete?
    return true if @change.blank? # No associated kafka message
    return true if @change['deleted_at'].present?
    return true if false_target?
    return true unless true_target?
    return true if record.blank? # No public Cocina
    return true if @skip_catkey && catkey?

    false
  end

  # Is the item released to this target?
  def true_target?
    @target.in? Array(@change['true_targets']).map(&:downcase)
  end

  # Is the item excluded from release to this target?
  def false_target?
    @target.in? Array(@change['false_targets']).map(&:downcase)
  end

  # Does the item have a catkey?
  def catkey?
    @change['catkey'].present? || record.folio_hrid.present?
  end

  # Public cocina record for the item
  def record
    @record = @cocina_service.fetch_record(@druid) if @record.equal?(RECORD_NOT_FETCHED)
    @record
  end

  # Remove items from the index
  def process_deletes(druids)
    @solr_service.delete_by_ids(druids) if druids.any?
  end

  # Update item in the index
  def process_update
    @solr_service.update(record)
  end
end
