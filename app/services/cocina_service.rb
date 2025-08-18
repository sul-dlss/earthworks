# Retrieve public Cocina records from PURL
class CocinaService
  # Fetch the public Cocina JSON and parse into a hash
  # TODO: https://github.com/sul-dlss/earthworks/issues/1537
  def self.fetch_record(druid)
    Rails.logger.info "Fetching metadata for druid:#{druid}"
  end
end
