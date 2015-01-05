require 'rails_helper'

describe GeomonitorConcern do
  let(:document) { SolrDocument.new(document_attributes) }
  describe 'available?' do
    describe 'for Stanford resources' do
      let(:document_attributes) {
        {
          dct_provenance_s: 'Stanford',
          dc_rights_s: 'Restricted'
        }
      }
      it 'should call super logic' do
        expect(document.available?).to be_truthy
      end
    end
    describe 'for resources less than threshold tolerance' do
      let(:document_attributes) {
        {
          dct_provenance_s: 'Harvard',
          dc_rights_s: 'Restricted',
          layer_availability_score_f: 0.6
        }
      }
      it 'should not be avilable' do
        expect(document.available?).to be_falsey
      end
    end
  end
  describe 'score_meets_threshold?' do
    let(:document_attributes) { {} }
    it 'no score present' do
      expect(document.score_meets_threshold?).to be_truthy
    end
  end
end
