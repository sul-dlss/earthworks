# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = Settings.RECAPTCHA.SITE_KEY
  config.secret_key = Settings.RECAPTCHA.SECRET_KEY
  config.skip_verify_env = 'development'
end
