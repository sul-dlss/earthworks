# override the default behavior so we can override the root engine path to run all checks
OkComputer.mount_at = false

# rubocop:disable Layout/ArgumentAlignment
OkComputer::Registry.register 'solr',
  OkComputer::HttpCheck.new(Blacklight.default_index.connection.uri.to_s.sub(%r{/$}, '') + '/admin/ping')

OkComputer::Registry.register 'downloads-cache',
  OkComputer::DirectoryCheck.new(
    Settings.DOWNLOAD_PATH || (Rails.root + 'tmp/cache/downloads').to_s, true
  )
# rubocop:enable Layout/ArgumentAlignment
