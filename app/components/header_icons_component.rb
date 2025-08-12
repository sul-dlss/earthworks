# frozen_string_literal: true

class HeaderIconsComponent < Geoblacklight::HeaderIconsComponent
  def get_icon(field)
    specific_field = helpers.get_specific_field_type(document: @document, field:)
    [helpers.geoblacklight_icon(specific_field), specific_field]
  end
end
