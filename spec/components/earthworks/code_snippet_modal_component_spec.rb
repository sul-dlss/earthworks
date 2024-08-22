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
      dct_references_s: references,
      gbl_resourceType_sm: resource_type
    }
  end

  describe 'Initial view for modal' do
    let(:resource_type) { ['Raster data'] }
    let(:document) { SolrDocument.new(document_attributes) }
    let(:references) { '{"http://www.opengis.net/def/serviceType/ogc/wms":"http://test.com/wms"}' }

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

    # Check that the code portion has value correctly subsituted
    it 'correctly subsitutes WXS identifier' do
      expect(rendered).to have_content('druid:abc123')
    end

    it 'correctly subsitutes layer id' do
      expect(rendered).to have_content('layer_name = "abc123"')
    end
  end

  describe 'Raster data view' do
    let(:resource_type) { ['Raster data'] }
    let(:document) { SolrDocument.new(document_attributes) }
    let(:references) { '{"http://www.opengis.net/def/serviceType/ogc/wms":"http://test.com/wms"}' }

    it 'correctly substitutes WMS endpoint' do
      expect(rendered).to have_content('http://test.com/wms')
    end

    it 'correctly substitutes bounding box values' do
      expect(rendered).to have_content('[3.416667, 172.666667], [-1.975, 176.05]')
    end
  end

  describe 'Vector data view' do
    let(:resource_type) { ['Vector data'] }
    let(:document) { SolrDocument.new(document_attributes) }
    let(:references) { '{"http://www.opengis.net/def/serviceType/ogc/wfs":"http://test.com/wfs"}' }

    it 'correctly substitutes WFS endpoint' do
      expect(rendered).to have_content('http://test.com/wfs')
    end
  end

  describe 'Solr document has empty or missing geometry' do
    let(:document) { SolrDocument.new({ id: 'abc123' }) }

    it 'correctly subsitutes placeholder values' do
      expect(rendered).to have_content('[Insert bounding box min X value]')
      expect(rendered).to have_content('[Insert bounding box min Y value]')
      expect(rendered).to have_content('[Insert bounding box max X value]')
      expect(rendered).to have_content('[Insert bounding box max Y value]')
    end
  end

  describe 'Vector data record has missing ids or WFS reference' do
    let(:document) do
      SolrDocument.new({ id: 'abc123',
                         locn_geometry: 'ENVELOPE(172.666667, 176.05, 3.416667, -1.975)',
                         gbl_resourceType_sm: ['Vector data'] })
    end

    it 'correctly subsitutes WXS ID placeholder value' do
      expect(rendered).to have_content('[Insert Web Services ID]')
    end

    it 'correctly subsitutes WFS placeholder value' do
      expect(rendered).to have_content('[Insert WFS endpoint]')
    end
  end

  describe 'Raster data has missing layer id or WMS reference' do
    let(:document) do
      SolrDocument.new({ id: 'abc123',
                         locn_geometry: 'ENVELOPE(172.666667, 176.05, 3.416667, -1.975)',
                         gbl_resourceType_sm: ['Raster data'] })
    end

    it 'correctly subsitutes WMS placeholder value' do
      expect(rendered).to have_content('[Insert WMS endpoint]')
    end

    it 'correctly subsitutes layer id placeholder value' do
      expect(rendered).to have_content('[Insert Layer ID]')
    end
  end
end
