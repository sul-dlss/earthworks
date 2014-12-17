class WmsController < ApplicationController

  before_action :format_url
  def handle
    response = WmsLayer.new(params).get_feature_info

    respond_to do |format|
      format.json { render json: response }
    end
  end

  def format_url
    params['URL'] = params['URL'].gsub(/.+?(?=\/geoserver)/, Settings.RESTRICTED_URL) if params['URL'] =~ /#{Settings.PROXY_URL}.*/
  end
end
