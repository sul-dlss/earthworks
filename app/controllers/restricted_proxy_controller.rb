class RestrictedProxyController < ApplicationController
  before_action :authenticate_user!

  def access
    proxied_headers.each do |k, v|
      headers[k] = v
    end
    self.status = proxied_response.status
    self.response_body = proxied_response.body
  end

  private
  
  def request_url
    request.url.gsub(Settings.PROXY_URL, Settings.RESTRICTED_URL)
  end

  def proxied_response
    @proxied_response ||= begin
      benchmark "Fetch #{request_url}" do
        HTTP.get(request_url)
      end
    end
  end

  def proxied_headers
    proxied_response.headers.select do |k, v|
      k == 'Content-Disposition' ||
      k == 'Content-Type' ||
      k.match(/Geowebcache/)
    end
  end
end
