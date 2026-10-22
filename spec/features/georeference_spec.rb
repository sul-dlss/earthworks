require 'rails_helper'

RSpec.describe 'Show page' do
  context 'when gbl_georeferenced_b is not set' do
    it 'does not show the georeference alert' do
      visit solr_document_path 'berkeley-s7st30'
      expect(page).to have_text '2000 Census Block Groups'
      expect(page).to have_no_text 'This item is not georeferenced.'
    end
  end

  context 'when gbl_georeferenced_b is set to true' do
    it 'does not show the georeference alert' do
      visit solr_document_path 'stanford-bc576pk4911'
      expect(page).to have_text 'Clearwater, Los Angeles Co., Cal.'
      expect(page).to have_no_text 'This item is not georeferenced.'
    end
  end

  context 'when gbl_georeferenced_b is set to false' do
    it 'shows the georeference alert' do
      visit solr_document_path 'the-related-record'
      expect(page).to have_text 'The Related Record'
      expect(page).to have_text 'This item is not georeferenced.'
    end
  end
end
