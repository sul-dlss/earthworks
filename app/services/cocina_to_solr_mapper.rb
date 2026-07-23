# Maps a Cocina record to a Solr document
class CocinaToSolrMapper
  # @param [CocinaDisplay::CocinaRecord] record
  def self.map(record)
    new(record).map
  end

  # @param [CocinaDisplay::CocinaRecord] record
  def initialize(record)
    @record = record
  end

  def map # rubocop:disable Metrics/AbcSize
    @doc = {}
    @doc['id'] = "stanford-#{record.bare_druid}"
    @doc['hashed_id_ssi'] = Digest::MD5.hexdigest(@doc['id'])
    @doc['dct_title_s'] = record.display_title || '[Untitled]'
    @doc['dct_alternative_sm'] = record.additional_titles
    @doc['dct_description_sm'] = map_description
    @doc['dct_language_sm'] = record.languages.map(&:code)
    @doc['dct_creator_sm'] = record.author_names
    @doc['dct_publisher_sm'] = record.publisher_names
    @doc['dct_issued_s'] = record.pub_year_int&.to_s
    @doc['dct_subject_sm'] = record.subject_topics
    @doc['dct_spatial_sm'] = record.subject_places
    @doc['dcat_theme_sm'] = TranslationMap.new('geo_theme').translate(@doc['dct_subject_sm'])
    @doc['dct_temporal_sm'] = record.subject_temporal

    years = extract_years(@doc['dct_temporal_sm'])
    if years.any?
      @doc['gbl_dateRange_drsim'] = ["[#{years.first} TO #{years.last}]"]
      @doc['gbl_indexYear_im'] = (years.first..years.last).to_a
    end

    @doc['schema_provider_s'] = 'Stanford'
    @doc['dct_identifier_sm'] = [record.purl_url, record.doi_url].compact

    @doc['gbl_georeferenced_b'] = georeferenced?

    @doc['gbl_resourceClass_sm'] = map_resource_class
    @doc['gbl_resourceType_sm'] = map_resource_type
    @doc['dct_format_s'] = map_format

    @doc['locn_geometry'] = record.coordinates_as_envelope&.first
    @doc['dcat_bbox'] = @doc['locn_geometry']

    @doc['dct_relation_sm'] = record.urls.select do |url|
      url.link_text == 'Georeferenced map in EarthWorks'
    end.map(&:to_s)

    @doc['pcdm_memberOf_sm'] = record.containing_collections.map { |c| "stanford-#{c}" }
    @doc['dct_source_sm'] = map_source

    @doc['dct_rights_sm'] = record.use_and_reproduction
    @doc['dct_rightsHolder_sm'] = record.copyright
    @doc['dct_license_sm'] = record.license
    @doc['dct_accessRights_s'] = record.world_access? ? 'Public' : 'Restricted'
    @doc['gbl_mdModified_dt'] = record.modified_time.strftime('%Y-%m-%dT%H:%M:%SZ')
    @doc['gbl_mdVersion_s'] = 'Aardvark'
    @doc['dct_references_s'] = map_references.to_json

    @doc.compact
  end

  private

  attr_reader :record

  def map_description
    skip_types = ['Local note', 'Preferred citation', 'Supplemental information', 'Donor tags']
    record.notes.reject { |note| skip_types.include?(note.label) }.map(&:to_s)
  end

  def map_resource_class
    return ['Maps'] if index_map? # Special case: don't treat it as a dataset

    res = TranslationMap.new('geo_resource_class')
                        .translate(record.all_forms.map(&:to_s) + record.genres + record.subject_genres)
    res = ['Collections'] if record.collection?
    res << 'Other' if res.empty?
    res.uniq
  end

  def map_resource_type
    res_types = TranslationMap.new('geo_resource_type').translate(record.all_forms.map(&:to_s) + record.subject_topics)
    return res_types.without('Polygon data', 'Point data') if index_map? # Special case: don't treat it as a dataset

    res_types.uniq
  end

  # @return [String]
  def map_format
    TranslationMap.new('geo_format').translate(record.all_forms.map(&:to_s) + record.file_mime_types).first
  end

  def map_source
    record.related_resources
          .select { |res| res.type == 'has other format' && res.label == 'Scanned map' }
          .flat_map { |res| res.identifiers.map { |id| id.value&.split('/')&.last } }
          .grep(/[a-z]{2}\d{3}[a-z]{2}\d{4}/)
          .map { |id| "stanford-#{id}" }
          .uniq
  end

  def map_references
    refs = {}

    # URLs
    refs['http://schema.org/url'] = record.purl_url
    refs['https://oembed.com'] = record.oembed_url(params: { hide_title: true })
    refs['http://iiif.io/api/presentation#manifest'] = record.iiif_manifest_url if iiif_viewable?
    refs['http://schema.org/thumbnailUrl'] = record.thumbnail_url
    refs['https://schema.org/relatedLink'] = record.searchworks_url

    # Files
    add_file_reference(refs, 'https://openindexmaps.org', filename: /index_map\.(json|geojson)/)
    add_file_reference(refs, 'http://www.isotc211.org/schemas/2005/gmd', filename: /iso19139\.xml/)
    add_file_reference(refs, 'http://www.isotc211.org/schemas/2005/gco', filename: /iso19110\.xml/)
    add_file_reference(refs, 'http://www.opengis.net/cat/csw/csdgm', filename: /fgdc\.xml/)
    add_file_reference(refs, 'http://geojson.org/geojson-spec.html', filename: /\.geojson/)
    add_file_reference(refs, 'https://github.com/protomaps/PMTiles', filename: /\.pmtiles/)
    add_file_reference(refs, 'https://github.com/cogeotiff/cog-spec', filename: /\.tif/, mime_type: /cloud-optimized/)
    add_file_reference(refs, 'https://iiif.io/api/extension/georef/1/context.json', use: 'georeference')

    # Downloads
    downloads = []
    downloads << { url: record.download_url, label: 'Zipped object' } if record.download_url.present?
    add_file_download(downloads, 'FlatGeoBuf', filename: /\.fgb/)
    refs['http://schema.org/downloadUrl'] = downloads if downloads.any?

    refs.compact
  end

  def add_file_download(downloads, label, **)
    file = record.files(**).first
    downloads << { url: file.download_url, label: label } if file.present?
  end

  def add_file_reference(refs, reference_type, **)
    file = record.files(**).first
    refs[reference_type] = file.download_url if file.present?
  end

  def extract_years(values)
    Array(values).flat_map { |v| v.to_s.scan(/\d{4}/) }.map(&:to_i).uniq.sort
  end

  # Determine if an object is georeferenced
  # Used for the gbl_georeferenced_b field:
  # https://opengeometadata.org/ogm-aardvark/#georeferenced
  def georeferenced?
    # All geo items (vector and raster data) are georeferenced
    return true if record.content_type == 'geo'

    # For other data, only georeferenced if annotations are present
    return true if record.files(use: 'georeference').any?

    false
  end

  # Object types with actually useful IIIF manifests
  def iiif_viewable?
    %(map image).include?(record.content_type)
  end

  # Use the subjects to check if this is an index map
  def index_map?
    record.subject_topics.include?('Index maps')
  end
end
