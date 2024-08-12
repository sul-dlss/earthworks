require 'rails_helper'

describe 'Show page' do
  context 'when gbl_georeferenced_b is not set' do
    it 'have georeference alert' do
      visit solr_document_path 'stanford-dt131hw5005'
      expect(page).to have_content 'This map is not georeferenced.'
    end
  end

  context 'when gbl_georeferenced_b is set to true' do
    it 'does not have georeference alert' do
      visit solr_document_path 'princeton-02870w62c'
      expect(page).to have_no_content 'This map is not georeferenced.'
    end
  end

  context 'when page is a non iiif page' do
    it 'does not have georeference alert' do
      visit solr_document_path 'mit-001145244'
      expect(page).to have_no_content 'This map is not georeferenced.'
    end
  end
end
