source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1'

# Successor to sprockets. https://github.com/rails/propshaft
gem "propshaft"

# Use Puma as the app server
gem 'puma', '~> 6'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Rubocop is a static code analyzer to enforce style.
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'rubocop-performance', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'debug'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'dotenv'
  gem 'simplecov', require: false
  gem 'solr_wrapper'
  gem 'sqlite3', '~> 1.7'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'dlss-capistrano'
  gem 'capistrano-shared_configs'
  gem 'capistrano-passenger'
  gem "ed25519", "~> 1.3"
  gem "bcrypt_pbkdf", "~> 1.1"
end

group :production do
  gem 'pg'
end

#gem 'blacklight', '~> 8.3'
gem 'blacklight', github: 'projectblacklight/blacklight', branch: 'main'
gem 'rsolr' # required for Blacklight
gem 'geoblacklight', github: 'geoblacklight/geoblacklight', branch: 'main'
gem 'faraday', '~> 2.0'
gem "devise"
gem "devise-guests", ">= 0.3.3"
gem 'devise-remote-user'
gem 'okcomputer'
gem 'honeybadger'
gem 'blacklight_dynamic_sitemap', '~> 0.3'
gem 'newrelic_rpm'
gem 'twitter-typeahead-rails'
gem 'blacklight_range_limit', '~> 7.0'
gem 'redis', '~> 5.0'
# Not compatible with GeoBlacklight 4.x
# https://github.com/geoblacklight/geo_monitor/issues/12
# gem 'geo_monitor', '~> 0.7', github: 'geoblacklight/geo_monitor'
gem 'geo_combine', '>= 0.9' # For OpenGeoMetadata indexing
gem 'sidekiq', '~> 7.0'
gem 'whenever', require: false
gem 'bootstrap', '~> 5.3'
gem 'rack-attack' # For throttle configuration
gem 'recaptcha', '>= 5.4.1'
gem 'http'
gem "cssbundling-rails", "~> 1.4"
gem "importmap-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"
gem "turbo-rails", "~> 2.0"
