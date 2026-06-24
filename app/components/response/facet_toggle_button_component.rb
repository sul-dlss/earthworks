module Response
  class FacetToggleButtonComponent < Blacklight::Response::FacetToggleButtonComponent
    # Override blacklight to use primary button style and display at medium breakpoint and stretch to full width
    def initialize(**)
      super
      @classes = 'btn btn-outline-primary facet-toggle-button d-block d-md-none col-12'
    end
  end
end
