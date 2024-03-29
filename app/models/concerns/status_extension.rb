module StatusExtension
  extend ActiveSupport::Concern
  included do
    after_commit :update_index
  end

  def update_index
    data = [{
      layer_availability_score_f: { set: layer.availability_score },
      id: layer.id
    }]
    Indexer.new.solr_update(data)
  end
end
