module WmsRewriteConcern
  extend Geoblacklight::SolrDocument

  def viewer_endpoint
    if stanford? && restricted?
      # replace wms prefix with webauthed proxy
      super.gsub(%r{.+?(?=/geoserver)}, Settings.PROXY_URL)
    else
      super
    end
  end
end
