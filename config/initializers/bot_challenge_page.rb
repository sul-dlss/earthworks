# rubocop:disable Layout/LineLength
BotChallengePage.configure do |config|
  # If disabled, no challenges will be issued
  config.enabled = Settings.turnstile.enabled

  # Get from CloudFlare Turnstile: https://www.cloudflare.com/application-services/products/turnstile/
  # Some testing keys are also available: https://developers.cloudflare.com/turnstile/troubleshooting/testing/
  #
  # This set of keys will always pass the challenge; the link above includes
  # sets that will always challenge or always fail, which is useful for local testing
  config.cf_turnstile_sitekey = Settings.turnstile.site_key
  config.cf_turnstile_secret_key = Settings.turnstile.secret_key

  # Do the challenge "in place" on the page the user was on
  config.redirect_for_challenge = false

  # How long will a challenge success exempt a session from further challenges?
  # config.session_passed_good_for = 36.hours

  # Exempt async JS facet requests from the challenge. Someone really determined could fake
  # this header, but until we see that behavior, we'll allow it so the facet UI works.
  # We also have an exception for index json so that the mini-bento frontend fetch in Searchworks doesn't get blocked.
  # Also exempt any IPs contained in the CIDR blocks in Settings.turnstile.safelist.
  config.skip_when = lambda do |_config|
    (is_a?(CatalogController) && params[:action].in?(%w[facet index]) && request.format.json? && request.headers['sec-fetch-dest'] == 'empty') ||
      Settings.turnstile.safelist.map { |cidr| IPAddr.new(cidr) }.any? { |range| request.remote_ip.in?(range) }
  end

  # More configuration is available; see:
  # https://github.com/samvera-labs/bot_challenge_page/blob/main/app/models/bot_challenge_page/config.rb
end
# rubocop:enable Layout/LineLength
