Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || Settings.REDIS_URL }
end
