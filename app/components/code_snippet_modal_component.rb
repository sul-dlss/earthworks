# frozen_string_literal: true

class CodeSnippetModalComponent < ViewComponent::Base
  def initialize(document)
    @document = document
    @raster_data_type = raster_data?
    @vector_data_type = vector_data?
    super
  end

  def code_block(content)
    sanitize "<pre><code>#{h content}</code></pre>"
  end

  def render_python
    substitute_values(retrieve_text('Python'))
  end

  def render_r
    substitute_values(retrieve_text('R'))
  end

  def render_leaflet
    substitute_values(retrieve_text('Leaflet'))
  end

  # Incorporate
  def substitute_values(content)
    sub_content = content

    # replace WXS_ID
    sub_content = sub_content.gsub('<<WXS_ID>>',
                                   substitute_id_value(@document.wxs_identifier, '[Insert Web Services ID]'))

    # If layer id is required
    sub_content = sub_content.gsub('<<LAYER_ID>>',
                                   substitute_id_value(layer_id, '[Insert Layer ID]'))

    # replace WMS reference
    sub_content = sub_content.gsub('<<GEOSERVER_WMS>>',
                                   substitute_webservice_value(@document.references.wms, '[Insert WMS endpoint]'))

    # replace WFS reference
    sub_content = sub_content.gsub('<<GEOSERVER_WFS>>',
                                   substitute_webservice_value(@document.references.wfs, '[Insert WFS endpoint]'))

    # Replace Bounding box information
    if @document.geom_field.blank? || @document.geometry.geom.blank?
      # If geometry information is not available, subsitute the coordinates with placeholder text
      sub_content = sub_content.gsub('<<MIN_X>>', '[Insert bounding box min X value]')
      sub_content = sub_content.gsub('<<MIN_Y>>', '[Insert bounding box min Y value]')
      sub_content = sub_content.gsub('<<MAX_X>>', '[Insert bounding box max X value]')
      sub_content = sub_content.gsub('<<MAX_Y>>', '[Insert bounding box max Y value]')
    else
      geometry = @document.geometry.geom
      bbox_array = geometry.split('ENVELOPE(')[1].split(')')[0].split(',').map(&:strip)

      if bbox_array.length == 4
        min_x = bbox_array[0]
        max_x = bbox_array[1]
        min_y = bbox_array[2]
        max_y = bbox_array[3]

        sub_content = sub_content.gsub('<<MIN_X>>', min_x)
        sub_content = sub_content.gsub('<<MIN_Y>>', min_y)
        sub_content = sub_content.gsub('<<MAX_X>>', max_x)
        sub_content = sub_content.gsub('<<MAX_Y>>', max_y)
      end
    end
    sub_content
  end

  def layer_id
    # If the Solr document has a wxs_identifier field, handle two cases:
    # if the string has 'druid:', return the portion after this prefix.
    # Otherwise, return the whole string.  The latter case is for other institutions' data.
    if @document.wxs_identifier.present?
      wxs_id = @document.wxs_identifier
      return wxs_id.include?('druid:') ? wxs_id.split('druid:')[1] : wxs_id
    end

    nil
  end

  def substitute_id_value(value, placeholder_value)
    value.presence || placeholder_value
  end

  def substitute_webservice_value(webservice, placeholder_value)
    webservice.nil? || webservice.endpoint.nil? ? placeholder_value : webservice.endpoint
  end

  private

  # Get the code sample text based on the data type and programming language
  def retrieve_text(language)
    file_name = code_sample_file_name(language)
    return if file_name.empty?

    File.read(Rails.root.join('config', 'code_samples', file_name).to_s).to_s
  end

  def vector_data?
    return false unless @document.key?(Settings.FIELDS.RESOURCE_TYPE)

    vector_types = ['polygon data', 'point data', 'line data', 'index maps',
                    'vector data']

    # If the intersection of these arrays is not empty, then there is at least one vector type value
    !(@document[Settings.FIELDS.RESOURCE_TYPE].map(&:downcase) &
      vector_types).empty?
  end

  def raster_data?
    return false unless @document.key?(Settings.FIELDS.RESOURCE_TYPE)

    @document[Settings.FIELDS.RESOURCE_TYPE].map(&:downcase).include?('raster data')
  end

  def code_sample_file_name(language)
    case language
    when 'Python'
      @vector_data_type ? 'vector_python.txt' : 'raster_python.txt'
    when 'Leaflet'
      @vector_data_type ? 'vector_leaflet.txt' : 'raster_leaflet.txt'
    when 'R'
      @vector_data_type ? 'vector_r.txt' : 'raster_r.txt'
    end
  end
end
