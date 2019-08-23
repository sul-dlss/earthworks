module GeomonitorConcern
  extend Geoblacklight::SolrDocument

  def available?
    index_map? || (score_meets_threshold? && super)
  end

  def index_map?
    references.index_map.present?
  end

  def score_meets_threshold?
    score = fetch(:layer_availability_score_f, {})
    if score.present?
      score > Settings.GEOMONITOR_TOLERANCE
    else
      true
    end
  end
end
