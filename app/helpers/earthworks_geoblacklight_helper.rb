module EarthworksGeoblacklightHelper
  include GeoblacklightHelper

  def document_available?
    (@document.public? && @document.available?) ||
      (@document.same_institution? && user_signed_in? && @document.available?)
  end

  ##
  # Override from GeoBlacklight to include custom `featured` param
  def has_search_parameters?
    params[:featured].present? || super
  end

  ##
  # Override from GeoBlacklight to include custom `featured` param
  def render_constraints_filters(localized_params = params)
    content = super(localized_params)
    localized_params = localized_params.to_unsafe_h unless localized_params.is_a?(Hash)

    if localized_params[:featured]
      value = localized_params[:featured].humanize.split.map(&:capitalize).join(' ')
      path = search_action_path(remove_spatial_filter_group(:featured, localized_params))
      content << render_constraint_element('Featured', value, remove: path)
    end

    content
  end
end
