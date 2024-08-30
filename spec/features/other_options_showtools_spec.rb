# frozen_string_literal: true

require 'rails_helper'

describe 'Display relevant links in Other Options section' do
  context 'when dataset is publicly available' do
    before do
      visit solr_document_path 'stanford-cz128vq0535'
    end

    it 'includes the correct code snippet link with modal trigger' do
      expect(page).to have_css("a[href='/catalog/stanford-cz128vq0535/code_snippet'][data-blacklight-modal='trigger']")
    end

    it 'contains the code snippets text' do
      expect(page).to have_content('Code Snippets')
    end
  end

  context 'when dataset is restricted' do
    before do
      visit solr_document_path 'stanford-cg357zz0321'
    end

    it 'does not contain the code snippets text' do
      expect(page).to have_no_content('Code Snippets')
    end
  end
end
