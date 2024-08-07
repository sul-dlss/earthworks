# frozen_string_literal: true

module Earthworks
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

      # replace DRUID_ID
      sub_content = sub_content.gsub('<<WXS_ID>>', @document.wxs_identifier) unless @document.wxs_identifier.empty?

      # If layer id is required
      sub_content = sub_content.gsub('<<LAYER_ID>>', layer_id) unless layer_id.nil?

      # replace WMS reference
      unless @document.references.wms.nil? || @document.references.wms.endpoint.nil?
        sub_content = sub_content.gsub('<<GEOSERVER_WMS>>', @document.references.wms.endpoint)
      end

      # replace WFS reference
      unless @document.references.wfs.nil? || @document.references.wfs.endpoint.nil?
        sub_content = sub_content.gsub('<<GEOSERVER_WFS>>', @document.references.wfs.endpoint)
      end

      # Replace Bounding box information
      unless @document.geom_field.empty?
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
      # If the Solr document either does not have a wxs identifier or does not have the "druid:" prefix
      unless @document.wxs_identifier.empty? || @document.wxs_identifier.exclude?('druid:')
        return @document.wxs_identifier.split('druid:')[1]
      end

      nil
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
end
