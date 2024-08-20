# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  let(:contents) { JSON.parse(Rails.root.join('spec', 'fixtures', 'solr_documents', file_name).read) }
  let(:document) { described_class.new(contents) }

  context 'when document is without file_formats' do
    let(:file_name) { 'collection.json' }

    it 'has image? returns nil' do
      expect(document.image?).to be_nil
    end
  end

  context 'when document has file_formats of JPEG 2000' do
    let(:file_name) { 'stanford-dy750qs3024.json' }

    it 'has image? returns true' do
      expect(document.image?).to be true
    end
  end

  context 'when document has file_format of Paper' do
    let(:file_name) { 'actual-papermap1.json' }

    it 'has image? returns false' do
      expect(document.image?).to be false
    end
  end
end
