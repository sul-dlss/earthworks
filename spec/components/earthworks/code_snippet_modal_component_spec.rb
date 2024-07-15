# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Earthworks::CodeSnippetModalComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document))
  end

  let(:document_attributes) do
    {
      id: 'abc123', gbl_wxsIdentifier_s: 'druid:abc123',
      locn_geometry: 'ENVELOPE(172.666667, 176.05, 3.416667, -1.975)',
      dcat_bbox: 'ENVELOPE(172.666667, 176.05, 3.416667, -1.975)',
      dct_references_s: '{"http://www.opengis.net/def/serviceType/ogc/wms":"wms"}',
      gbl_resourceType_sm: resource_type
    }
  end

  describe 'Initial view for modal' do
    let(:resource_type) { ['Raster data'] }
    let(:document) { SolrDocument.new(document_attributes) }

    it 'displays Python language link' do
      expect(rendered).to have_css('.code-snippet-tab#python-tab')
    end

    it 'displays R language link' do
      expect(rendered).to have_css('.code-snippet-tab#r-tab')
    end

    it 'displays Leaflet language link' do
      expect(rendered).to have_css('.code-snippet-tab#leaflet-tab')
    end

    it 'displays Copy button' do
      expect(rendered).to have_button('copyClipboard')
    end

    it 'correctly subsitutes WXS identifier' do
      expect(rendered).to have_content('druid:abc123')
    end
  end

  describe 'Raster data view' do
    let(:resource_type) { ['Raster data'] }
    let(:document) { SolrDocument.new(document_attributes) }

    it 'correctly substitutes WMS endpoint' do
      expect(rendered).to have_content('wms')
    end
  end

  describe 'Vector data view' do
    let(:resource_type) { ['Vector data'] }
    let(:document) { SolrDocument.new(document_attributes) }

    it 'correctly substitutes WFS endpoint' do
      expect(rendered).to have_content('wfs')
    end
  end
end
