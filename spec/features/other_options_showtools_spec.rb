# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Display relevant links in Other Options section' do
  context 'when dataset is publicly available' do
    before do
      visit solr_document_path 'stanford-bc576pk4911'
    end

    it 'includes the correct code snippet link with modal trigger' do
      expect(page).to have_css("a[href='/catalog/stanford-bc576pk4911/code_snippet'][data-blacklight-modal='trigger']")
    end

    it 'contains the code snippets text' do
      expect(page).to have_text('Code Snippets')
    end
  end

  context 'when dataset is restricted' do
    before do
      visit solr_document_path 'stanford-dp018hs9766'
    end

    it 'does not contain the code snippets text' do
      expect(page).to have_no_text('Code Snippets')
    end
  end
end
