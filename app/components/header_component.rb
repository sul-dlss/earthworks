# frozen_string_literal: true

class HeaderComponent < Blacklight::HeaderComponent
  def landing_page?
    current_page?(root_path) && !helpers.has_search_parameters?
  end
end
