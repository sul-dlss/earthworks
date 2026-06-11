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
      @doc['date_hierarchy_sm'] = hierarchicalize_year_list(@doc['gbl_indexYear_im'])
    end

    @doc['schema_provider_s'] = 'Stanford'
    @doc['dct_identifier_sm'] = [record.purl_url, record.doi_url].compact

    @doc['gbl_georeferenced_b'] = @doc['dct_title_s'].include?('(Raster Image)')

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
    res = TranslationMap.new('geo_resource_class')
                        .translate(record.all_forms.map(&:to_s) + record.genres + record.subject_genres)
    res += %w[Maps Datasets] if @doc['gbl_georeferenced_b']
    res = ['Collections'] if record.collection?
    res << 'Other' if res.empty?
    res.uniq
  end

  def map_resource_type
    TranslationMap.new('geo_resource_type').translate(record.all_forms.map(&:to_s) + record.subject_topics)
  end

  def map_format
    TranslationMap.new('geo_format').translate(record.all_forms.map(&:to_s) + record.file_mime_types)
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
    refs['http://schema.org/url'] = record.purl_url
    if record.download_url.present?
      refs['http://schema.org/downloadUrl'] = [{ url: record.download_url, label: 'Zipped object' }]
    end
    refs['https://oembed.com'] = record.oembed_url(params: { hide_title: true })
    refs['http://iiif.io/api/presentation#manifest'] = iiif_manifest_url
    refs['http://schema.org/thumbnailUrl'] = record.thumbnail_url
    refs['https://schema.org/relatedLink'] = searchworks_url
    iiif_annotation = record.files(mime_type: 'application/json', use: 'georeference')
                            .map { |file| stacks_file_url(file.filename) }.first
    refs['https://iiif.io/api/extension/georef/1/context.json'] = iiif_annotation

    # Files
    add_file_reference(refs, /index_map\.(json|geojson)/, 'https://openindexmaps.org')
    add_file_reference(refs, /iso19139\.xml/, 'http://www.isotc211.org/schemas/2005/gmd')
    add_file_reference(refs, /iso19110\.xml/, 'http://www.isotc211.org/schemas/2005/gco')
    add_file_reference(refs, /fgdc\.xml/, 'http://www.opengis.net/cat/csw/csdgm')
    add_file_reference(refs, /\.geojson/, 'http://geojson.org/geojson-spec.html')
    add_file_reference(refs, /\.pmtiles/, 'https://github.com/protomaps/PMTiles')
    add_file_reference(refs, /\.tif/, 'https://github.com/cogeotiff/cog-spec', mime_type: /cloud-optimized/)

    refs.compact
  end

  def add_file_reference(refs, filename_regex, reference_type, mime_type: nil)
    file = record.files.find do |f|
      f.filename =~ filename_regex && (mime_type.nil? || f.mime_type =~ mime_type)
    end
    refs[reference_type] = stacks_file_url(file.filename) if file
  end

  def stacks_file_url(filename)
    "https://stacks.stanford.edu/file/druid:#{record.bare_druid}/#{filename}"
  end

  def iiif_manifest_url
    "https://purl.stanford.edu/#{record.bare_druid}/iiif/manifest"
  end

  def searchworks_url
    "https://searchworks.stanford.edu/view/#{record.bare_druid}"
  end

  def extract_years(values)
    Array(values).flat_map { |v| v.to_s.scan(/\d{4}/) }.map(&:to_i).uniq.sort
  end

  def hierarchicalize_year_list(years)
    years.flat_map do |year|
      century = (year / 100) * 100
      decade = (year / 10) * 10
      [
        "#{century}-#{century + 99}",
        "#{century}-#{century + 99}:#{decade}-#{decade + 9}",
        "#{century}-#{century + 99}:#{decade}-#{decade + 9}:#{year}"
      ]
    end.uniq
  end
end
