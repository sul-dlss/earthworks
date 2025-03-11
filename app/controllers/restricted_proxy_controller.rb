class RestrictedProxyController < ApplicationController
  before_action :headers_auth

  def headers_auth
    JWT.decode(request.params['stacks_token'], Settings.geo_proxy_secret, true, { algorithm: 'HS256' })
    set_cors_headers
  rescue JWT::ExpiredSignature
    render json: { error: 'Expired token' }, status: :unauthorized
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def set_cors_headers
    origin = request.origin
    permitted_origins = [Settings.cors.allow_origin_url]
    if permitted_origins.include?(origin)
      response.headers['Access-Control-Allow-Origin'] = origin
      response.headers['Access-Control-Allow-Credentials'] = true
    else
      response.headers['Access-Control-Allow-Origin'] = '*'
    end
  end

  def access
    proxied_headers.each do |k, v|
      headers[k] = v
    end

    self.status = proxied_response.status
    send_data proxied_response.body, type: proxied_response.headers['Content-Type'], disposition: 'inline'
  end

  private

  def request_url
    request.url.gsub(Settings.PROXY_URL, Settings.RESTRICTED_URL)
  end

  def proxied_response
    @proxied_response ||= benchmark "Fetch #{request_url}" do
      HTTP.get(request_url)
    end
  end

  def proxied_headers
    proxied_response.headers.select do |k, _v|
      k == 'content-disposition' ||
        k == 'content-type' ||
        k.include?('geowebcache')
    end
  end
end
