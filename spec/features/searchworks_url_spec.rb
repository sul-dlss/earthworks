require 'rails_helper'

describe 'Searchworks urls' do
  context 'when a document has a searchworks url' do
    it 'shows it' do
      visit solr_document_path 'stanford-dt131hw5005'
      expect(page).to have_link 'View in Searchworks'
    end
  end

  context 'when a document does not have a searchworks url' do
    it 'does not shows it' do
      visit solr_document_path 'stanford-cg357zz0321'
      expect(page).to have_no_link 'View in Searchworks'
    end
  end
end
