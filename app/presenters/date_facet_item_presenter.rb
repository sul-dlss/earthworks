# frozen_string_literal: true

# Format dates for display
class DateFacetItemPresenter < Blacklight::FacetItemPivotPresenter
  def label
    century, decade, year = value.split(':')
    [year, decade, century].find(&:present?) # label is just the finest level of granularity available
  end
end
