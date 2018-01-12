module StatusExtension
  extend ActiveSupport::Concern
  included do
    after_commit :update_index
  end

  def update_index
    data = [{
      layer_availability_score_f: { set: layer.availability_score },
      layer_slug_s: layer.slug
    }]
    Indexer.new.solr_update(data)
  end
end
