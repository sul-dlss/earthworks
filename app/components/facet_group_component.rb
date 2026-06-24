# frozen_string_literal: true

class FacetGroupComponent < Blacklight::Response::FacetGroupComponent
  # Override blacklight switch from d-lg-block
  def body_classes
    'facets-collapse d-md-block collapse accordion'
  end

  # Override blacklight to so this disappears at medium breakpoint
  def header_classes
    'facets-heading d-none d-md-block'
  end

  def button_component
    Response::FacetToggleButtonComponent
  end
end
