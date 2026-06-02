class WmsController < ApplicationController
  before_action :format_url
  ##
  # TODO: Consolidate this somehow with GeoBlacklight's `wms_params` permitted
  # parameters
  def handle
    response = Geoblacklight::WmsLayer.new(params.to_unsafe_hash).feature_info

    respond_to do |format|
      format.json { render json: response }
    end
  end

  def format_url
    return unless /#{Settings.proxy_url}.*/.match?(params['URL'])

    params['URL'] = params.expect('URL').gsub(%r{.+?(?=/geoserver)}, Settings.restricted_url)
  end
end
