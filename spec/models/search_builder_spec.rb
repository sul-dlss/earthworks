require 'rails_helper'

describe SearchBuilder do
  let(:user_params) { Hash.new }
  let(:solr_params) { Hash.new }
  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:context) { CatalogController.new }

  let(:search_builder) { described_class.new(context) }

  subject { search_builder.with(user_params) }

  describe '#add_spatial_params' do
    it 'should return the solr_params when no bbox is given' do
      expect(subject.add_spatial_params(solr_params)).to eq solr_params
    end

    it 'should return a spatial search if bbox is given' do
      params = { bbox: '-180 -80 120 80' }
      subject.with(params)
      expect(subject.add_spatial_params(solr_params)[:fq].to_s)
        .to include('Intersects')
      expect(subject.add_spatial_params(solr_params)[:bq].to_s)
        .to match(/.*IsWithin.*\^300/)
    end
  end
  describe '#add_featured_content' do
    context 'scanned maps' do
      it do
        params = { featured: 'scanned_maps' }
        subject.with(params)
        expect(subject.add_featured_content(solr_params)[:fq]).to eq [
          'layer_geom_type_s:Image OR layer_geom_type_s:"Paper Map"'
        ]
      end
    end
    context 'geospatial data' do
      it do
        params = { featured: 'geospatial_data' }
        subject.with(params)
        expect(subject.add_featured_content(solr_params)[:fq]).to eq [
          '-layer_geom_type_s:Image AND -layer_geom_type_s:"Paper Map" AND -la'\
          'yer_geom_type_s:Mixed AND -layer_geom_type_s:Table'
        ]
      end
    end
    context 'census data' do
      it do
        params = { featured: 'census_data' }
        subject.with(params)
        expect(subject.add_featured_content(solr_params)[:fq]).to eq [
          'dc_title_ti:census OR dc_description_ti:census OR dc_publisher_ti:c'\
          'ensus OR dc_subject_tmi:census'
        ]
      end
    end
    context 'california data' do
      it do
        params = { featured: 'california_data' }
        subject.with(params)
        expect(subject.add_featured_content(solr_params)[:fq]).to eq [
          'dc_title_ti:california OR dc_description_ti:california OR dc_publis'\
          'her_ti:california OR dc_subject_tmi:california'
        ]
      end
    end
  end
end
