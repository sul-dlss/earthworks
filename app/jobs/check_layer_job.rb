class CheckLayerJob < ApplicationJob
  queue_as :default

  ##
  # @param [GeoMonitor::Layer] layer
  def perform(layer)
    # See if in Solr first, if not, deactivate and exit
    num_found = Blacklight.default_index.connection.get(
      'select',
      params: { q: "layer_slug_s:#{layer.slug}", fl: 'layer_slug_s' }
    )['response']['numFound'].to_i
    if num_found > 0
      layer.check
    else
      layer.update(active: false)
    end
  end
end
