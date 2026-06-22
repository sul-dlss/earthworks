# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe Document::AccessComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(document:)) }

  context 'with a CC license' do
    let(:contents) { JSON.parse(Rails.root.join('spec/fixtures/solr_documents/stanford-dy750qs3024.json').read) }
    let(:document) { SolrDocument.new(contents) }

    it 'renders the human-friendly license description' do
      expect(rendered).to have_css 'dt', text: 'License'
      expect(rendered).to have_css 'dd',
                                   text: 'This work is licensed under a Creative Commons Attribution Non Commercial 3.0 Unported license (CC BY-NC).'
    end

    it 'shows external links in more details' do
      expect(rendered).to have_link 'https://purl.stanford.edu/dy750qs3024', href: 'https://purl.stanford.edu/dy750qs3024'
      expect(rendered).to have_link 'https://doi.org/10.7946/P2Z31V', href: 'https://doi.org/10.7946/P2Z31V'
    end
  end

  context 'with an ODC license' do
    let(:contents) { JSON.parse(Rails.root.join('spec/fixtures/solr_documents/stanford_odbl.json').read) }
    let(:document) { SolrDocument.new(contents) }

    it 'renders the human-friendly license description' do
      expect(rendered).to have_css 'dt', text: 'License'
      expect(rendered).to have_css 'dd',
                                   text: 'This work is licensed under an Open Data Commons Open Database License v1.0.'
    end
  end

  context 'with an unknown license' do
    let(:contents) { JSON.parse(Rails.root.join('spec/fixtures/solr_documents/harvard_raster.json').read) }
    let(:document) { SolrDocument.new(contents) }

    it 'renders the license URI' do
      expect(rendered).to have_css 'dt', text: 'License'
      expect(rendered).to have_css 'dd', text: 'example.com/license'
    end

    it 'does not show the more details section' do
      expect(rendered).to have_no_text 'More details at'
    end
  end
end
# rubocop:enable Layout/LineLength
