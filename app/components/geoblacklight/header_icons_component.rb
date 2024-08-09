# frozen_string_literal: true

module Geoblacklight
  class HeaderIconsComponent < ViewComponent::Base
    attr_reader :document, :fields, :icon_name

    def initialize(document:,
                   fields: [Settings.FIELDS.RESOURCE_CLASS, Settings.FIELDS.PROVIDER, Settings.FIELDS.ACCESS_RIGHTS])
      @document = document
      @fields = fields
      super
    end

    def get_icon(field)
      icon_name = @document[field]
      if icon_name&.include?('Datasets') && @document[Settings.FIELDS.RESOURCE_TYPE]
        specific_icon = @document[Settings.FIELDS.RESOURCE_TYPE]
        specific_icon = specific_icon.first if specific_icon.is_a?(Array)
        specific_icon = specific_icon&.gsub(' data', '')
        icon = geoblacklight_icon(specific_icon)
        return [icon, specific_icon] unless icon.include?('icon-missing')
      end
      icon_name = icon_name.first if icon_name.is_a?(Array)
      [geoblacklight_icon(icon_name), icon_name]
    end
  end
end
