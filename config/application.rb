require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Earthworks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.autoloader = :classic # Our helper overrides don't work under the new loader
    config.application_name = 'EarthWorks'

    # Inject our StatusExtension concern to add behavior
    # (index updates) to the GeoMonitor::Status class
    config.to_prepare do
      GeoMonitor::Status.send(:include, StatusExtension)
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
