require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActionMailer::Base.default from: 'no-reply@earthworks.stanford.edu'

module Earthworks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.application_name = 'EarthWorks'

    require 'rights_metadata'
    # Inject our StatusExtension concern to add behavior
    # (index updates) to the GeoMonitor::Status class
    # Disabled until v4.x compatibility is resolved
    # https://github.com/geoblacklight/geo_monitor/issues/12
    # config.to_prepare do
    #   GeoMonitor::Status.include StatusExtension
    # end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
