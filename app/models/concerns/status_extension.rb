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
    Blacklight.default_index.connection.update(
      params: { commitWithin: commit_within, overwrite: true },
      data: data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def commit_within
    ENV['SOLR_COMMIT_WITHIN'] || Settings.SOLR_COMMIT_WITHIN || 5000
  end
end
