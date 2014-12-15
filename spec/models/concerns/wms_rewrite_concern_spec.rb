require 'rails_helper'

describe WmsRewriteConcern do
  let(:document) { SolrDocument.new(document_attributes) }
  describe 'viewer_endpoint' do
    describe 'for stanford restricted' do
      let(:document_attributes) { { 
        dct_provenance_s: 'Stanford',
        dc_rights_s: 'Restricted',
        dct_references_s: {
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://www.example.com/geoserver/wms'
        }.to_json
      } }
      it 'should rewrite url' do
        expect(document.viewer_endpoint).to eq 'http://www.example.com/restricted/geoserver/wms'
      end
    end
    describe 'for not stanford or public' do
      let(:document_attributes) { {
        dct_provenance_s: 'Princeton',
        dc_rights_s: 'Restricted',
        dct_references_s: {
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://www.example.com/geoserver/wms'
        }.to_json
      } }
      it 'should not rewrite url' do
        expect(document.viewer_endpoint).to eq 'http://www.example.com/geoserver/wms'
      end
    end
  end
  describe 'is_stanford_restricted?' do
    describe 'for Stanford and Restricted' do
      let(:document_attributes) { { dct_provenance_s: 'Stanford', dc_rights_s: 'Restricted' } }
      it 'identifies restricted stanford documents' do
        expect(document.is_stanford_restricted?).to be_truthy
      end
    end
    describe 'for Stanford public' do
      let(:document_attributes) { { dct_provenance_s: 'Stanford', dc_rights_s: 'Public' } }
      it 'requires both conditions' do
        expect(document.is_stanford_restricted?).to be_falsey
      end
    end
  end
  describe 'stanford?' do
    describe 'for stanford' do
      let(:document_attributes) { { dct_provenance_s: 'Stanford' } }
      it 'identifies stanford documents' do
        expect(document.stanford?).to be_truthy
      end
    end
    describe 'for non stanford' do
      let(:document_attributes) { { dct_provenance_s: 'Princeton' } }
      it 'identifies stanford documents' do
        expect(document.stanford?).to be_falsey
      end
    end
  end
end
