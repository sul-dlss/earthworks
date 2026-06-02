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
      files: [],
      download_url: 'https://stacks.stanford.edu/file/druid:abc12345678/data.zip',
      oembed_url: 'https://purl.stanford.edu/abc12345678/embed',
      thumbnail_url: 'https://stacks.stanford.edu/file/druid:abc12345678/thumb.jpg'
    )
  end

  describe '.map' do
    subject(:doc) { described_class.map(record) }

    it 'maps cocina record to solr document' do
      expect(doc['id']).to eq 'stanford-abc12345678'
      expect(doc['dct_title_s']).to eq 'Test Title'
      expect(doc['dcat_theme_sm']).to eq ['Agriculture']
      expect(doc['gbl_indexYear_im']).to eq [2024]
      expect(doc['dct_accessRights_s']).to eq 'Public'
    end

    context 'with restricted access' do
      before do
        allow(record).to receive(:world_access?).and_return(false)
      end

      it 'handles restricted access' do
        expect(doc['dct_accessRights_s']).to eq 'Restricted'
      end
    end

    context 'with georeferenced title' do
      before do
        allow(record).to receive(:display_title).and_return('Test Title (Raster Image)')
      end

      it 'handles georeferenced title' do
        expect(doc['gbl_georeferenced_b']).to be true
        expect(doc['gbl_resourceClass_sm']).to include 'Datasets'
      end
    end
  end
end
