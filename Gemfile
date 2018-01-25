source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development
gem 'listen', group: :development

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'coveralls', '>= 0.8.21', require: false
  gem 'simplecov', require: false
  gem 'solr_wrapper'
  gem 'sqlite3'
  gem 'byebug'
end


group :deployment do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'dlss-capistrano'
  gem 'capistrano-sidekiq'
  gem 'capistrano-shared_configs'
end

group :production do
  gem 'pg'
end

gem "blacklight"
gem "geoblacklight"
gem "devise"
gem "devise-guests", "~> 0.3.3"
gem 'devise-remote-user'
gem 'is_it_working'
gem 'honeybadger'
gem 'sitemap_generator', '~> 5.0.5'
gem 'newrelic_rpm'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'blacklight_range_limit'
gem 'rsolr'
gem 'geo_combine', git: 'https://github.com/OpenGeoMetadata/GeoCombine.git', branch: 'master'
gem 'geo_monitor', '~> 0.4'
gem 'sidekiq'
gem 'whenever', require: false
