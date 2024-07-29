# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
describe 'License rendering' do
  context 'with a CC license' do
    it 'renders the human-friendly license description' do
      visit solr_document_path 'stanford-dy750qs3024'
      expect(page).to have_css 'dt', text: 'License'
      expect(page).to have_css 'dd',
                               text: 'This work is licensed under a Creative Commons Attribution Non Commercial 3.0 Unported license (CC BY-NC).'
    end
  end

  context 'with an ODC license' do
    it 'renders the human-friendly license description' do
      visit solr_document_path 'stanford-cj936rq6257'
      expect(page).to have_css 'dt', text: 'License'
      expect(page).to have_css 'dd',
                               text: 'This work is licensed under an Open Data Commons Open Database License v1.0.'
    end
  end

  context 'with an unknown license' do
    it 'renders the license URI' do
      visit solr_document_path 'harvard-g7064-s2-1834-k3'
      expect(page).to have_css 'dt', text: 'License'
      expect(page).to have_css 'dd', text: 'example.com/license'
    end
  end
end
# rubocop:enable Layout/LineLength
