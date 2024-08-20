require 'rails_helper'

describe 'More detail links' do
  context 'when a document has a purl and doi' do
    it 'shows them in more details' do
      visit solr_document_path 'stanford-dy750qs3024'
      expect(page).to have_link 'https://purl.stanford.edu/dy750qs3024'
      expect(page).to have_link 'https://doi.org/10.7946/P2Z31V'
    end
  end
end
