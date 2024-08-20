# frozen_string_literal: true

# This was copied out of Blacklight 8.  We can remove this file when we upgrade.
module Blacklight
  module Icons
    # This is the magnifing glass icon for the search button.
    # You can override the default svg by setting:
    #   Blacklight::Icons::SearchComponent.svg = '<svg>your SVG here</svg>'
    class SearchComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        Search
      SVG
    end
  end
end
