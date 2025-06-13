# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeaderIconsComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document:))
  end

  let(:document_attributes) do
    {
      id: 'abc123', gbl_wxsIdentifier_s: 'druid:abc123',
      gbl_resourceClass_sm: resource_class,
      gbl_resourceType_sm: resource_type
    }
  end

  let(:document) { SolrDocument.new(document_attributes) }

  describe 'Imagery resource class' do
    let(:resource_class) { 'Imagery' }

    context 'when resource type with an icon' do
      let(:resource_type) { ['Raster data'] }

      it 'returns the resource type' do
        expect(rendered).to have_text('Imagery')
      end
    end
  end

  describe 'Dataset resource class' do
    let(:resource_class) { 'Datasets' }

    context 'when a resource type with an icon' do
      let(:resource_type) { ['Raster data'] }

      it 'returns the resource type' do
        expect(rendered).to have_text('Raster')
      end
    end

    context 'when a resource type without an icon' do
      let(:resource_type) { ['Military maps'] }

      it 'returns the resource class' do
        expect(rendered).to have_text('Datasets')
      end
    end
  end
end
