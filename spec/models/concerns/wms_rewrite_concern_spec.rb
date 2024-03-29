require 'rails_helper'

describe WmsRewriteConcern do
  let(:document) { SolrDocument.new(document_attributes) }

  describe 'viewer_endpoint' do
    describe 'for stanford restricted' do
      let(:document_attributes) do
        {
          schema_provider_s: 'Stanford',
          dct_accessRights_s: 'Restricted',
          dct_references_s: {
            'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://www.example.com/geoserver/wms'
          }.to_json
        }
      end

      it 'rewrites url' do
        expect(document.viewer_endpoint).to eq 'http://www.example.com/restricted/geoserver/wms'
      end
    end

    describe 'for not stanford or public' do
      let(:document_attributes) do
        {
          schema_provider_s: 'Princeton',
          dct_accessRights_s: 'Restricted',
          dct_references_s: {
            'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://www.example.com/geoserver/wms'
          }.to_json
        }
      end

      it 'does not rewrite url' do
        expect(document.viewer_endpoint).to eq 'http://www.example.com/geoserver/wms'
      end
    end
  end

  describe 'stanford?' do
    describe 'for stanford' do
      let(:document_attributes) { { schema_provider_s: 'Stanford' } }

      it 'identifies stanford documents' do
        expect(document.stanford?).to be_truthy
      end
    end

    describe 'for non stanford' do
      let(:document_attributes) { { schema_provider_s: 'Princeton' } }

      it 'identifies stanford documents' do
        expect(document.stanford?).to be_falsey
      end
    end
  end
end
