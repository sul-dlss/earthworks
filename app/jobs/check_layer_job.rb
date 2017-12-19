class CheckLayerJob < ApplicationJob
  queue_as :default

  ##
  # @param [GeoMonitor::Layer] layer
  def perform(layer)
    layer.check
  end
end
