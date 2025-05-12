class StaticMapComponent < Geoblacklight::StaticMapComponent
  def render?
    document.item_viewer.iiif_manifest || document.item_viewer.iiif
  end
end
