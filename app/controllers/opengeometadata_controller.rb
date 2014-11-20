require 'json'

class OpengeometadataController < ApplicationController

  SRCDIR = '/var/cache/opengeometadata'
  
  def show
    # load parameters
    @institution = params[:institution]
    @layer_id = params[:layer_id]
    @metadata_format = params[:metadata_format] || 'iso19139'
    @metadata_format = 'iso19139' if @metadata_format == 'default'

    # construct the layer's UUID
    @uuid = "#{@institution}:#{@layer_id}"
        
    # if there's a layers.json mapping then use it
    json_fn = "#{SRCDIR}/#{@institution}/layers.json"
    if File.size?(json_fn)
      layers = JSON.parse(File.open(json_fn).read)
      layer_path = layers[@uuid]      
      raise ActiveRecord::RecordNotFound.new("Layer is not registered: #{@uuid}") if layer_path.nil?
    else
      # ... otherwise locate as-is
      layer_path = @layer_id
    end
    
    # validate that we actually hold this layer
    fn = File.join(SRCDIR, @institution, layer_path)
    raise ActiveRecord::RecordNotFound.new("Layer is not available: #{@uuid}") unless File.directory?(fn)
    
    # ...and in the given format

    # show the layer now
    respond_to do |format|
      fn = File.join(fn, "#{@metadata_format}.#{params[:format]}")
      raise ActiveRecord::RecordNotFound.new("Layer is not available in #{@metadata_format.upcase} format as #{params[:format].upcase}") unless File.size?(fn)
      
      format.xml { send_file fn, :disposition => 'inline', type: 'text/xml' }
      format.html { send_file fn, :disposition => 'inline', type: 'text/html' }
    end
  end


end
