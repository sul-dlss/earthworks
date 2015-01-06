module GeomonitorConcern
  extend Geoblacklight::SolrDocument

  def available?
    score_meets_threshold? && super
  end

  def score_meets_threshold?
    score = get(:layer_availability_score_f)
    if score.present?
      score > Settings.GEOMONITOR_TOLERANCE
    else
      true
    end
  end
end
