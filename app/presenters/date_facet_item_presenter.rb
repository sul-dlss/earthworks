# frozen_string_literal: true

# Format dates for display
class DateFacetItemPresenter < Blacklight::FacetItemPivotPresenter
  # Choose the finest granularity available and trim leading zeroes
  # 0100-0199 -> 100-199
  def label
    century, decade, year = value.split(':')
    finest = [year, decade, century].find(&:present?)
    finest.sub!(/^0+(\d+)/, '\1')
    finest.sub!(/-0+(\d+)/, '-\1')
    finest
  end
end
