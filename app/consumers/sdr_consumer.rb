# Harvest items published from SDR for indexing
class SdrConsumer < Racecar::Consumer
  subscribes_to Settings.kafka.topic
  self.group_id = Settings.kafka.group_id

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

  # Process a single message from the Kafka queue; key is the druid
  def process(message)
    @druid = message.key.delete_prefix('druid:')
    @change = JSON.parse(message.value) if message.value.present?
    delete? ? process_delete : process_update
  rescue StandardError => e
    Honeybadger.notify(e)
    raise e
  end

  private

  # Determine if the item should be removed from the index
  def delete?
    return true if @change.blank? # No associated kafka message
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
    @cocina_service.fetch_record(@druid)
  end

  # Remove item from the index
  def process_delete
    @solr_service.delete_by_id(@druid)
  end

  # Update item in the index
  def process_update
    @solr_service.update(record)
  end
end
