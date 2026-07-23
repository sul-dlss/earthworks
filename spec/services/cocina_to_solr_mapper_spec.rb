require 'rails_helper'

RSpec.describe CocinaToSolrMapper do
  subject(:doc) { described_class.map(record) }

  let(:record) { CocinaDisplay::CocinaRecord.from_json(File.read("spec/fixtures/cocina_documents/#{druid}.json")) }
  let(:references) { JSON.parse(doc['dct_references_s']) }

  context 'with a stanford-only polygon shapefile' do
    let(:druid) { 'bb099zb1450' }

    it 'has resource class of Datasets' do
      expect(doc['gbl_resourceClass_sm']).to eq ['Datasets']
    end

    it 'has resource type of Polygon data' do
      expect(doc['gbl_resourceType_sm']).to eq ['Polygon data']
    end

    it 'maps the subjects that are valid DCAT themes' do
      expect(doc['dcat_theme_sm']).to eq ['Boundaries']
    end

    it 'maps the format' do
      expect(doc['dct_format_s']).to eq 'Shapefile'
    end

    it 'is georeferenced' do
      expect(doc['gbl_georeferenced_b']).to be true
    end

    it 'maps the collections' do
      expect(doc['pcdm_memberOf_sm']).to eq ['stanford-wn457nv9847']
    end

    it 'maps the access as restricted' do
      expect(doc['dct_accessRights_s']).to eq 'Restricted'
    end

    it 'maps a PURL link as canonical URL' do
      expect(references['http://schema.org/url']).to eq 'https://purl.stanford.edu/bb099zb1450'
    end

    it 'maps a SearchWorks link as relatedLink' do
      expect(references['https://schema.org/relatedLink']).to eq 'https://searchworks.stanford.edu/view/bb099zb1450'
    end

    it 'has an ISO 19139 XML reference' do
      expect(references['http://www.isotc211.org/schemas/2005/gmd']).to eq 'https://stacks.stanford.edu/file/druid:bb099zb1450/D31_dep-iso19139.xml'
    end

    it 'has an FGDC XML reference' do
      expect(references['http://www.opengis.net/cat/csw/csdgm']).to eq 'https://stacks.stanford.edu/file/druid:bb099zb1450/D31_dep-fgdc.xml'
    end

    it 'has an ISO 19110 XML reference' do
      expect(references['http://www.isotc211.org/schemas/2005/gco']).to eq 'https://stacks.stanford.edu/file/druid:bb099zb1450/D31_dep-iso19110.xml'
    end

    it 'has a PMTiles reference' do
      expect(references['https://github.com/protomaps/PMTiles']).to eq 'https://stacks.stanford.edu/file/druid:bb099zb1450/D31_dep.pmtiles'
    end

    it 'has a thumbnail URL reference' do
      expect(references['http://schema.org/thumbnailUrl']).to eq 'https://stacks.stanford.edu/image/iiif/bb099zb1450%2FD31_dep/full/!400,400/0/default.jpg'
    end

    it 'has a zipfile download' do
      expect(references['http://schema.org/downloadUrl']).to include(
        {
          'url' => 'https://stacks.stanford.edu/object/bb099zb1450',
          'label' => 'Zipped object'
        }
      )
    end

    it 'has a FlatGeoBuf download' do
      expect(references['http://schema.org/downloadUrl']).to include(
        {
          'url' => 'https://stacks.stanford.edu/file/druid:bb099zb1450/D31_dep.fgb',
          'label' => 'FlatGeoBuf'
        }
      )
    end
  end

  context 'with a public geoTIFF' do
    let(:druid) { 'bb223nv3920' }

    it 'has resource class of Datasets' do
      expect(doc['gbl_resourceClass_sm']).to eq ['Datasets']
    end

    it 'has resource type of Raster data' do
      expect(doc['gbl_resourceType_sm']).to eq ['Raster data']
    end

    it 'maps the subjects that are valid DCAT themes' do
      expect(doc['dcat_theme_sm']).to eq ['Society']
    end

    it 'maps the format' do
      expect(doc['dct_format_s']).to eq 'GeoTIFF'
    end

    it 'is georeferenced' do
      expect(doc['gbl_georeferenced_b']).to be true
    end

    it 'maps the access as public' do
      expect(doc['dct_accessRights_s']).to eq 'Public'
    end

    it 'maps the collections' do
      expect(doc['pcdm_memberOf_sm']).to eq ['stanford-rr276tj2464']
    end

    it 'maps a PURL link as canonical URL' do
      expect(references['http://schema.org/url']).to eq 'https://purl.stanford.edu/bb223nv3920'
    end

    it 'maps a SearchWorks link as relatedLink' do
      expect(references['https://schema.org/relatedLink']).to eq 'https://searchworks.stanford.edu/view/bb223nv3920'
    end

    it 'has an ISO 19139 XML reference' do
      expect(references['http://www.isotc211.org/schemas/2005/gmd']).to eq 'https://stacks.stanford.edu/file/druid:bb223nv3920/Pretoria_landcover_t1-iso19139.xml'
    end

    it 'has an FGDC XML reference' do
      expect(references['http://www.opengis.net/cat/csw/csdgm']).to eq 'https://stacks.stanford.edu/file/druid:bb223nv3920/Pretoria_landcover_t1-fgdc.xml'
    end

    it 'has a COG reference' do
      expect(references['https://github.com/cogeotiff/cog-spec']).to eq 'https://stacks.stanford.edu/file/druid:bb223nv3920/Pretoria_landcover_t1_cog.tif'
    end

    it 'has a thumbnail URL reference' do
      expect(references['http://schema.org/thumbnailUrl']).to eq 'https://stacks.stanford.edu/image/iiif/bb223nv3920%2FPretoria_landcover_t1/full/!400,400/0/default.jpg'
    end

    it 'has a zipfile download' do
      expect(references['http://schema.org/downloadUrl']).to include(
        {
          'url' => 'https://stacks.stanford.edu/object/bb223nv3920',
          'label' => 'Zipped object'
        }
      )
    end
  end

  context 'with a scanned map' do
    let(:druid) { 'bc592pz8308' }

    it 'has resource class of Maps' do
      expect(doc['gbl_resourceClass_sm']).to eq ['Maps']
    end

    it 'is not georeferenced' do
      expect(doc['gbl_georeferenced_b']).to be false
    end

    it 'maps a PURL link as canonical URL' do
      expect(references['http://schema.org/url']).to eq 'https://purl.stanford.edu/bc592pz8308'
    end

    it 'maps a SearchWorks link using the catkey as relatedLink' do
      expect(references['https://schema.org/relatedLink']).to eq 'https://searchworks.stanford.edu/view/a10624983'
    end

    it 'has a IIIF manifest reference' do
      expect(references['http://iiif.io/api/presentation#manifest']).to eq 'https://purl.stanford.edu/bc592pz8308/iiif3/manifest'
    end

    it 'has a thumbnail URL reference' do
      expect(references['http://schema.org/thumbnailUrl']).to eq 'https://stacks.stanford.edu/image/iiif/bc592pz8308%2Fbc592pz8308_05_0001/full/!400,400/0/default.jpg'
    end
  end

  context 'with a georeferenced scanned map' do
    let(:druid) { 'bb013fz9675' }

    it 'has resource class of Maps' do
      expect(doc['gbl_resourceClass_sm']).to eq ['Maps']
    end

    it 'is georeferenced' do
      expect(doc['gbl_georeferenced_b']).to be true
    end

    it 'maps a PURL link as canonical URL' do
      expect(references['http://schema.org/url']).to eq 'https://purl.stanford.edu/bb013fz9675'
    end

    it 'maps a SearchWorks link using the catkey as relatedLink' do
      expect(references['https://schema.org/relatedLink']).to eq 'https://searchworks.stanford.edu/view/a2941954'
    end

    it 'has a thumbnail URL reference' do
      expect(references['http://schema.org/thumbnailUrl']).to eq 'https://stacks.stanford.edu/image/iiif/bb013fz9675%2Fbb013fz9675_0001/full/!400,400/0/default.jpg'
    end

    it 'has a IIIF manifest reference' do
      expect(references['http://iiif.io/api/presentation#manifest']).to eq 'https://purl.stanford.edu/bb013fz9675/iiif3/manifest'
    end

    it 'has a georeference annotation reference' do
      expect(references['https://iiif.io/api/extension/georef/1/context.json']).to eq 'https://stacks.stanford.edu/file/druid:bb013fz9675/bb013fz9675_0001.json'
    end
  end

  context 'with an index map' do
    let(:druid) { 'bc576pk4911' }

    it 'has a resource class of Maps' do
      expect(doc['gbl_resourceClass_sm']).to eq ['Maps']
    end

    it 'has a resource type of Index maps' do
      expect(doc['gbl_resourceType_sm']).to eq ['Index maps']
    end

    it 'has an index map reference' do
      expect(references['https://openindexmaps.org']).to eq 'https://stacks.stanford.edu/file/druid:bc576pk4911/index_map.geojson'
    end
  end
end
