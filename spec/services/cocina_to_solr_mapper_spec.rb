require 'rails_helper'

RSpec.describe CocinaToSolrMapper do
  let(:record) do
    instance_double(
      CocinaDisplay::CocinaRecord,
      bare_druid: 'abc12345678',
      display_title: 'Test Title',
      additional_titles: [],
      notes: [],
      languages: [],
      author_names: [],
      publisher_names: [],
      pub_year_int: 2024,
      subject_topics: ['Agriculture'],
      subject_places: [],
      subject_temporal: ['2024'],
      purl_url: 'https://purl.stanford.edu/abc12345678',
      doi_url: nil,
      all_forms: ['map'],
      content_type: 'geo',
      genres: [],
      subject_genres: [],
      file_mime_types: [],
      coordinates_as_envelope: ['ENVELOPE(1, 2, 3, 4)'],
      urls: [],
      containing_collections: [],
      related_resources: [],
      use_and_reproduction: 'test rights',
      copyright: 'test copyright',
      license: 'test license',
      world_access?: true,
      modified_time: Time.zone.parse('2024-01-01'),
      collection?: false,
      download_url: 'https://stacks.stanford.edu/file/druid:abc12345678/data.zip',
      oembed_url: 'https://purl.stanford.edu/abc12345678/embed',
      thumbnail_url: 'https://stacks.stanford.edu/file/druid:abc12345678/thumb.jpg',
      iiif_manifest_url: 'https://purl.stanford.edu/abc12345678/iiif3/manifest',
      searchworks_url: 'https://searchworks.stanford.edu/view/abc12345678'
    )
  end

  describe '.map' do
    subject(:doc) { described_class.map(record) }

    let(:references) { JSON.parse(doc['dct_references_s']) }

    before do
      allow(record).to receive(:files).and_return([])
    end

    it 'maps cocina record to solr document' do
      expect(doc['id']).to eq 'stanford-abc12345678'
      expect(doc['dct_title_s']).to eq 'Test Title'
      expect(doc['dcat_theme_sm']).to eq ['Agriculture']
      expect(doc['gbl_indexYear_im']).to eq [2024]
      expect(doc['dct_accessRights_s']).to eq 'Public'
      expect(doc['gbl_georeferenced_b']).to be true
    end

    context 'with restricted access' do
      before do
        allow(record).to receive(:world_access?).and_return(false)
      end

      it 'handles restricted access' do
        expect(doc['dct_accessRights_s']).to eq 'Restricted'
      end
    end

    context 'with georeferenced scanned map' do
      before do
        allow(record).to receive(:files)
          .with(use: 'georeference')
          .and_return(
            [
              instance_double(
                CocinaDisplay::Structural::File,
                use: 'georeference',
                filename: 'iiif_georeference.json',
                download_url: 'https://stacks.stanford.edu/file/druid:abc12345678/iiif_georeference.json'
              )
            ]
          )
        allow(record).to receive(:content_type).and_return('map')
      end

      it 'is georeferenced' do
        expect(doc['gbl_georeferenced_b']).to be true
      end

      it 'adds the georeference annotation to dct_references_s' do
        expect(references['https://iiif.io/api/extension/georef/1/context.json']).to eq 'https://stacks.stanford.edu/file/druid:abc12345678/iiif_georeference.json'
      end
    end

    context 'with non-georeferenced scanned map' do
      before do
        allow(record).to receive(:content_type).and_return('map')
      end

      it 'is not georeferenced' do
        expect(doc['gbl_georeferenced_b']).to be false
      end
    end

    context 'when all_forms returns multiple formats' do
      before do
        allow(record).to receive(:all_forms).and_return(%w[Shapefile PMTiles])
      end

      it 'maps dct_format_s to only a single value' do
        expect(doc['dct_format_s']).to eq 'Shapefile'
      end
    end
  end
end
