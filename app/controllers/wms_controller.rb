class WmsController < ApplicationController

  before_action :format_url

  def format_url
    params['URL'] = params['URL'].gsub(/.+?(?=\/geoserver)/, Settings.RESTRICTED_URL) if params['URL'] =~ /#{Settings.PROXY_URL}.*/
  end
end
