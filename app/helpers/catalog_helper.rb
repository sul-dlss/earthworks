module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def get_specific_field_type(document:, field:, **)
    field_value = document[field]
    if field_value&.include?('Datasets') && document[Settings.FIELDS.RESOURCE_TYPE]
      specific_field_value = document[Settings.FIELDS.RESOURCE_TYPE]
      specific_field_value = specific_field_value.first if specific_field_value.is_a?(Array)
      specific_field_value = specific_field_value&.gsub(' data', '')
      return specific_field_value unless geoblacklight_icon(specific_field_value).include?('icon-missing')
    end
    field_value = field_value.first if field_value.is_a?(Array)
    field_value
  end
end
