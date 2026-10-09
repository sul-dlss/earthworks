# rubocop:disable Style/OneClassPerFile
# rubocop:disable Rails/SkipsModelValidations

require_relative '../config/environment'
require 'faraday/retry'

THREADS = ENV.fetch('THREADS', 12).to_i
BATCH_SIZE = ENV.fetch('BATCH_SIZE', 500).to_i

# Fetches Cocina for a whole batch of druids in parallel, then serves the
# records from memory. SdrConsumer keeps per-message state in instance variables
# (@druid, @change, @record), so it can't safely be run from multiple threads;
# this moves the slow part (network I/O) into threads and leaves the consumer's
# delete/update logic untouched.
class PrefetchingCocinaService
  class << self
    # Fetch every druid in the batch up front, THREADS at a time
    def warm(druids)
      @records = {}
      lock = Mutex.new

      druids.each_slice((druids.size.to_f / THREADS).ceil).map do |slice|
        Thread.new do
          slice.each do |druid|
            record = fetch(druid)
            lock.synchronize { @records[druid] = record }
          end
        end
      end.each(&:join)
    end

    # Called by SdrConsumer, which has already stripped the druid: prefix
    def fetch_record(druid)
      @records[druid]
    end

    private

    def fetch(druid)
      response = client.get("/#{druid}.json")
      raise "Unsuccessful response from purl: #{response.status}" unless response.success?

      CocinaDisplay::CocinaRecord.new(JSON.parse(response.body))
    rescue StandardError => e
      Rails.logger.error "Error fetching cocina record for #{druid}: #{e.message}"
      nil
    end

    # Multithreaded persistent client for fetching Cocina
    def client
      @client ||= Faraday.new(url: 'https://purl.stanford.edu') do |builder|
        builder.request :retry, max: 3, interval: 0.05, backoff_factor: 2
        builder.adapter :net_http_persistent, pool_size: THREADS
      end
    end
  end
end

# Buffers documents so we issue one Solr request per batch instead of one per
# record, and skips commitWithin so we aren't soft-committing throughout a bulk
# load. Deletes flush pending updates first to keep SdrConsumer's ordering.
class BufferedSolrService
  class << self
    def update(record)
      buffer << CocinaToSolrMapper.map(record)
    end

    def delete_by_ids(druids)
      flush
      SolrService.delete_by_ids(druids)
    end

    def flush
      return if buffer.empty?

      Rails.logger.info "Updating #{buffer.size} Solr documents"
      SolrService.connection.update(
        params: { overwrite: true },
        data: buffer.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      buffer.clear
    end

    private

    def buffer
      @buffer ||= []
    end
  end
end

# Fake a Kafka message saying to index this druid
Message = Struct.new(:key, :value)
def create_message(druid:)
  key = druid
  value = { true_targets: ['Earthworks'] }.to_json
  Message.new(key, value)
end

reader = PurlFetcher::Client::Reader.new
consumer = SdrConsumer.new(cocina_service: PrefetchingCocinaService, solr_service: BufferedSolrService)

items = reader.released_to('Earthworks').to_a
bar = ProgressBar.new(items.length)

items.each_slice(BATCH_SIZE) do |batch|
  druids = batch.map { |item| item['druid'].delete_prefix('druid:') }
  PrefetchingCocinaService.warm(druids)

  consumer.process_batch(batch.map { |item| create_message(druid: item['druid']) })
  BufferedSolrService.flush

  bar.increment!(batch.length)
end

SolrService.connection.commit

# rubocop:enable Style/OneClassPerFile
# rubocop:enable Rails/SkipsModelValidations
