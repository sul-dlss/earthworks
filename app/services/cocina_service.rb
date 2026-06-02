# Retrieve public Cocina records from PURL
class CocinaService
  # Fetch the public Cocina JSON and parse into a hash
  def self.fetch_record(druid)
    Rails.logger.info "Fetching metadata for druid:#{druid}"
    response = HTTP.get("https://#{Settings.purl.hostname}/#{druid}.json")
    raise "Unsuccessful response from purl: #{response.status}" unless response.status.success?

    CocinaDisplay::CocinaRecord.new(JSON.parse(response.body))
  rescue StandardError => e
    Rails.logger.error "Error fetching cocina record for #{druid}: #{e.message}"
    nil
  end
end
