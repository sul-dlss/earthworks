module WmsRewriteConcern
  extend Geoblacklight::SolrDocument

  def viewer_endpoint
    if is_stanford_restricted?
      # replace wms prefix with webauthed proxy
      super.gsub(%r{.+?(?=/geoserver)}, Settings.PROXY_URL)
    else
      super
    end
  end

  def is_stanford_restricted?
    stanford? && restricted?
  end

  def stanford?
    fetch(:dct_provenance_s).casecmp('stanford').zero?
  end
end
