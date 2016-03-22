require 'rails_helper'

describe WmsController do
  describe 'POST handle' do
    let(:wms_layer) { instance_double(Geoblacklight::WmsLayer) }

    it 'rewrites restricted urls for a proxy' do
      expect(wms_layer).to receive(:feature_info)
      expect(Geoblacklight::WmsLayer).to receive(:new).with(
        URL: 'http://www.example-services.com/geoserver',
        action: 'handle',
        format: 'json',
        controller: 'wms'
      ).and_return(wms_layer)
      post :handle, format: :json, URL: 'http://www.example.com/restricted/geoserver'
    end
  end
end
