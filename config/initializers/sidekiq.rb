Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Settings.redis_url } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { Settings.redis_url } }
end
