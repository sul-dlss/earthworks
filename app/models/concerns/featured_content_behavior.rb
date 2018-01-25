module FeaturedContentBehavior
  extend ActiveSupport::Concern

  def add_featured_content(solr_params)
    featured_content_params = send("#{blacklight_params[:featured]}_content_params")
    featured_content_params.each do |param|
      solr_params[:fq] ||= []
      solr_params[:fq] << param
    end

    solr_params
  rescue NoMethodError
    solr_params
  end

  private

  def scanned_maps_content_params
    [
      'layer_geom_type_s:Image OR layer_geom_type_s:"Paper Map"'
    ]
  end

  def geospatial_data_content_params
    [
      '-layer_geom_type_s:Image AND -layer_geom_type_s:"Paper Map" AND -layer_geom_type_s:Mixed AND -layer_geom_type_s:Table'
    ]
  end

  def census_data_content_params
    [
      'dc_title_ti:census OR dc_description_ti:census OR dc_publisher_ti:census OR dc_subject_tmi:census'
    ]
  end
  
  def california_data_content_params
    [
      'dc_title_ti:california OR dc_description_ti:california OR dc_publisher_ti:california OR dc_subject_tmi:california'
    ]
  end
end
