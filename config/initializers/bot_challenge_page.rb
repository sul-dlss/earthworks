# rubocop:disable Layout/LineLength
Rails.application.config.to_prepare do
  # If disabled, no challenges will be issued
  BotChallengePage::BotChallengePageController.bot_challenge_config.enabled = Settings.turnstile.enabled

  # Get from CloudFlare Turnstile: https://www.cloudflare.com/application-services/products/turnstile/
  # Some testing keys are also available: https://developers.cloudflare.com/turnstile/troubleshooting/testing/
  #
  # This set of keys will always pass the challenge; the link above includes
  # sets that will always challenge or always fail, which is useful for local testing
  BotChallengePage::BotChallengePageController.bot_challenge_config.cf_turnstile_sitekey = Settings.turnstile.site_key
  BotChallengePage::BotChallengePageController.bot_challenge_config.cf_turnstile_secret_key = Settings.turnstile.secret_key

  # Do the challenge "in place" on the page the user was on
  BotChallengePage::BotChallengePageController.bot_challenge_config.redirect_for_challenge = false

  # What paths do you want to protect?
  #
  # You can use path prefixes: "/catalog" or even "/"
  #
  # Or hashes with controller and/or action:
  #
  #   { controller: "catalog" }
  #   { controller: "catalog", action: "index" }
  #
  # Note that we can only protect GET paths, and also think about making sure you DON'T protect
  # any path your front-end needs JS `fetch` access to, as this would block it
  #
  # We protect CatalogController requests for searches, but not for show pages, so we can still
  # crawl ourselves and let well-behaved search engines index our content via the sitemap.
  BotChallengePage::BotChallengePageController.bot_challenge_config.rate_limited_locations = [
    { controller: 'catalog', action: 'index' }
  ]

  # Allow rate_limit_count requests in rate_limit_period, before issuing challenge
  # This is low because some bots rotate IPs, so we want to catch them quickly
  BotChallengePage::BotChallengePageController.bot_challenge_config.rate_limit_period = 24.hours
  BotChallengePage::BotChallengePageController.bot_challenge_config.rate_limit_count = 3

  # How long will a challenge success exempt a session from further challenges?
  # BotChallengePage::BotChallengePageController.bot_challenge_config.session_passed_good_for = 36.hours

  # Exempt async JS facet requests from the challenge. Someone really determined could fake
  # this header, but until we see that behavior, we'll allow it so the facet UI works.
  # Also exempt any IPs contained in the CIDR blocks in Settings.turnstile.safelist.
  BotChallengePage::BotChallengePageController.bot_challenge_config.allow_exempt = lambda do |controller, _config|
    (controller.is_a?(CatalogController) && controller.params[:action].in?(%w[facet]) && controller.request.headers['sec-fetch-dest'] == 'empty') ||
      Settings.turnstile.safelist.map { |cidr| IPAddr.new(cidr) }.any? { |range| controller.request.remote_ip.in?(range) }
  end

  # More configuration is available; see:
  # https://github.com/samvera-labs/bot_challenge_page/blob/main/app/models/bot_challenge_page/config.rb

  # This gets called last; we use rack_attack to do the rate limiting part
  BotChallengePage::BotChallengePageController.rack_attack_init
end
# rubocop:enable Layout/LineLength
