module GeomonitorConcern
  extend Geoblacklight::SolrDocument

  def available?
    score_meets_threshold? && super
  end

  def score_meets_threshold?
    score = fetch(:layer_availability_score_f, {})
    if score.present?
      score > Settings.geomonitor_tolerance
    else
      true
    end
  end
end
