source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'webdrivers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'solr_wrapper'
  gem 'sqlite3'
end


group :deployment do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'dlss-capistrano'
  gem 'capistrano-shared_configs'
  gem 'capistrano-passenger'
end

group :production do
  gem 'pg'
end

gem "blacklight"
gem "geoblacklight", '~> 3.0'
gem "devise"
gem "devise-guests", ">= 0.3.3"
gem 'devise-remote-user'
gem 'okcomputer'
gem 'honeybadger'
gem 'blacklight_dynamic_sitemap', '~> 0.3'
gem 'newrelic_rpm'
gem 'twitter-typeahead-rails'
gem 'blacklight_range_limit', '~> 7.0'
gem 'rsolr'
gem 'geo_combine'
gem 'geo_monitor', '~> 0.7'
gem 'sidekiq'
gem 'whenever', require: false
gem 'bootstrap'
gem 'rack-attack' # For throttle configuration
gem 'recaptcha', '>= 5.4.1'
gem 'http'
gem 'rexml' # see https://github.com/ruby-marc/ruby-marc/issues/67
