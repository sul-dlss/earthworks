# override the default behavior so we can override the root engine path to run all checks
OkComputer.mount_at = false

ping_url = "#{Blacklight.connection_config[:url].to_s.sub(%r{/$}, '')}/admin/ping"
OkComputer::Registry.register 'solr', OkComputer::HttpCheck.new(ping_url)

OkComputer::Registry.register 'downloads-cache',
                              OkComputer::DirectoryCheck.new(Geoblacklight.configuration.download_path, true)

OkComputer::Registry.register 'redis',
                              OkComputer::RedisCheck.new(url: ENV.fetch('REDIS_URL') { Settings.redis_url })

OkComputer.make_optional %w[redis]
