##
# See https://github.com/kickstarter/rack-attack/blob/master/docs/example_configuration.md
# for more configuration options
class Rack::Attack
  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  if Settings.THROTTLE_TRAFFIC
    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip unless req.path.start_with?('/assets') || req.params['format'] == 'json'
    end

    # Throttle search requests by IP (15rpm)
    Rack::Attack.throttle('req/search/ip', limit: 15, period: 1.minute) do |req|
      route = begin
        Rails.application.routes.recognize_path(req.path) || {}
      rescue StandardError
        {}
      end

      req.ip if route[:controller] == 'catalog' && (route[:action] == 'index' || route[:action] == 'facet')
    end

    # Throttle document actions requests by IP (15rpm)
    Rack::Attack.throttle('req/actions/ip', limit: 15, period: 1.minute) do |req|
      route = begin
        Rails.application.routes.recognize_path(req.path) || {}
      rescue StandardError
        {}
      end

      req.ip if route[:action].in? %w[email sms]
    end

    # Inform throttled clients about limits and when they will get out of jail
    Rack::Attack.throttled_response_retry_after_header = true
    Rack::Attack.throttled_responder = lambda do |request|
      match_data = request.env['rack.attack.match_data']
      now = match_data[:epoch_time]

      if Settings.throttling.notify_honeybadger && (
        ((match_data[:limit] - match_data[:count]) < 5) || (match_data[:count] % 10).zero?
      ) && (request.headers['HTTP_USER_AGENT'] || '') !~ /(Google|bot)/i
        Honeybadger.notify('Throttling request', context: { ip: request.ip, path: request.path }.merge(match_data))
      end

      headers = {
        'RateLimit-Limit' => match_data[:limit].to_s,
        'RateLimit-Remaining' => '0',
        'RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s
      }

      [429, headers, ["Throttled\n"]]
    end

    Settings.throttling.safelist.each do |ip_range|
      Rack::Attack.safelist_ip(ip_range)
    end
  end
end
