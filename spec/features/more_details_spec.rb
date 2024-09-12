require 'rails_helper'

describe 'More detail links' do
  context 'when a document has a purl and doi in its identifiers' do
    it 'shows them in more details' do
      visit solr_document_path 'stanford-dy750qs3024'
      expect(page).to have_link 'https://purl.stanford.edu/dy750qs3024'
      expect(page).to have_link 'https://doi.org/10.7946/P2Z31V'
    end
  end

  context 'when a document has no URLs in its identifiers' do
    it 'does not show the more details section' do
      visit solr_document_path 'harvard-g7064-s2-1834-k3'
      expect(page).to have_no_text 'More details at'
    end
  end
end
