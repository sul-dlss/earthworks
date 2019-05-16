# override the default behavior so we can override the root engine path to run all checks
OkComputer.mount_at = false

OkComputer::Registry.register "solr", OkComputer::HttpCheck.new(Blacklight.default_index.connection.uri.to_s.sub(/\/$/, '') + "/admin/ping")
OkComputer::Registry.register "downloads-cache", OkComputer::DirectoryCheck.new(Rails.root + "tmp/cache/downloads", true)
