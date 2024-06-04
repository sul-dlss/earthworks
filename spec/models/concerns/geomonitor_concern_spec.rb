require 'rails_helper'

RSpec.describe GeomonitorConcern, skip: 'needs GBLv4 compatibility' do
  let(:document) { SolrDocument.new(document_attributes) }

  describe 'available?' do
    describe 'for Stanford resources' do
      let(:document_attributes) do
        {
          schema_provider_s: 'Stanford',
          dct_accessRights_s: 'Restricted'
        }
      end

      it 'calls super logic' do
        expect(document.available?).to be true
      end
    end

    describe 'for resources less than threshold tolerance' do
      let(:document_attributes) do
        {
          schema_provider_s: 'Harvard',
          dct_accessRights_s: 'Restricted',
          layer_availability_score_f: 0.6
        }
      end

      it 'is not avilable' do
        expect(document.available?).to be false
      end
    end
  end

  describe 'score_meets_threshold?' do
    let(:document_attributes) { {} }

    it 'no score present' do
      expect(document.score_meets_threshold?).to be true
    end
  end
end
