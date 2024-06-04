require 'blacklight/catalog'
require 'legacy_id_map'

class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include Blacklight::Catalog

  rescue_from Blacklight::Exceptions::RecordNotFound, with: :redirect_from_legacy_id

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :start => 0,
      :rows => 10,
      'q.alt' => '*:*'
    }

    # Default parameters to send on single-document requests to Solr.
    # These settings are the Blacklight defaults (see SolrHelper#solr_doc_params) or
    # parameters included in the Blacklight-jetty document requestHandler.
    config.default_document_solr_params = {
      qt: 'document',
      q: '{!raw f=layer_slug_s v=$id}'
    }

    # solr field configuration for search results/index views
    # config.index.show_link = 'title_display'
    # config.index.record_display_type = 'format'

    config.index.title_field = 'dc_title_s'

    config.raw_endpoint.enabled = true

    config.crawler_detector = ->(req) { req.env['HTTP_USER_AGENT']&.include?('bot') }

    # solr field configuration for document/show views

    config.show.display_type_field = 'format'
    config.show.partials << 'rights_metadata'
    config.show.partials << 'show_message'
    config.show.partials << 'show_default_viewer_container'
    config.show.partials << 'show_default_attribute_table'
    config.show.partials << 'show_default_viewer_information'
    config.show.partials << 'show_default_canonical_link'

    ##
    # Configure the index document presenter.
    config.index.document_presenter_class = Geoblacklight::DocumentPresenter

    # Custom GeoBlacklight fields which currently map to GeoBlacklight-Schema
    # v0.3.2
    config.wxs_identifier_field = 'layer_id_s'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    # config.add_facet_field 'format', :label => 'Format'
    # config.add_facet_field 'pub_date', :label => 'Publication Year', :single => true
    # config.add_facet_field 'subject_topic_facet', :label => 'Topic', :limit => 20
    # config.add_facet_field 'language_facet', :label => 'Language', :limit => true
    # config.add_facet_field 'lc_1letter_facet', :label => 'Call Number'
    # config.add_facet_field 'subject_geo_facet', :label => 'Region'
    # config.add_facet_field 'solr_bbox', :fq => "solr_bbox:IsWithin(-88,26,-79,36)", :label => 'Spatial'

    # config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']

    # config.add_facet_field 'example_query_facet_field', :label => 'Publish Date', :query => {
    #    :years_5 => { :label => 'within 5 Years', :fq => "pub_date:[#{Time.now.year - 5 } TO *]" },
    #    :years_10 => { :label => 'within 10 Years', :fq => "pub_date:[#{Time.now.year - 10 } TO *]" },
    #    :years_25 => { :label => 'within 25 Years', :fq => "pub_date:[#{Time.now.year - 25 } TO *]" }
    # }

    config.add_facet_field Settings.FIELDS.PROVENANCE, label: 'Institution', limit: 8, partial: 'icon_facet'
    config.add_facet_field Settings.FIELDS.CREATOR, label: 'Author', limit: 6
    config.add_facet_field Settings.FIELDS.PUBLISHER, label: 'Publisher', limit: 6
    config.add_facet_field Settings.FIELDS.SUBJECT, label: 'Subject', limit: 6
    config.add_facet_field Settings.FIELDS.SPATIAL_COVERAGE, label: 'Place', limit: 6
    # config.add_facet_field 'dct_isPartOf_sm', :label => 'Collection', :limit => 6
    config.add_facet_field Settings.FIELDS.SOURCE, show: false, label: 'Collection'

    config.add_facet_field 'solr_year_i', label: 'Year', limit: 10, range: {
      # :num_segments => 6,
      assumed_boundaries: [0o001, 2016]
      # :segments => true
    }

    # Needed as a fallback for dc_rights_s facet selections that were previously linked, does not show up in UI
    config.add_facet_field 'dc_rights_s', label: 'Rights', partial: 'icon_facet', show: false

    config.add_facet_field 'access', label: 'Access',
                                     query: {
                                       restricted: {
                                         label: 'Restricted', fq: 'dc_rights_s:Restricted'
                                       },
                                       public: {
                                         label: 'Public', fq: 'dc_rights_s:Public'
                                       },
                                       available: {
                                         label: 'Available',
                                         fq: "(layer_availability_score_f:[#{Settings.GEOMONITOR_TOLERANCE} TO 1])"
                                       },
                                       unavailable: {
                                         label: 'Unavailable',
                                         fq: "layer_availability_score_f:[0 TO #{Settings.GEOMONITOR_TOLERANCE}]"
                                       }
                                     },
                                     partial: 'icon_facet'
    config.add_facet_field 'layer_geom_type_s', label: 'Data type', limit: 8, partial: 'icon_facet'
    config.add_facet_field 'dc_format_s', label: 'Format', limit: 3

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    # config.add_index_field 'title_display', :label => 'Title:'
    # config.add_index_field 'title_vern_display', :label => 'Title:'
    # config.add_index_field 'author_display', :label => 'Author:'
    # config.add_index_field 'author_vern_display', :label => 'Author:'
    # config.add_index_field 'format', :label => 'Format:'
    # config.add_index_field 'language_facet', :label => 'Language:'
    # config.add_index_field 'published_display', :label => 'Published:'
    # config.add_index_field 'published_vern_display', :label => 'Published:'
    # config.add_index_field 'lc_callnum_display', :label => 'Call number:'

    # config.add_index_field 'dc_title_t', :label => 'Display Name:'
    # config.add_index_field 'dct_provenance_s', :label => 'Institution:'
    # config.add_index_field 'dc_rights_s', :label => 'Access:'
    # # config.add_index_field 'Area', :label => 'Area:'
    # config.add_index_field 'dc_subject_sm', :label => 'Keywords:'
    config.add_index_field Settings.FIELDS.YEAR
    config.add_index_field Settings.FIELDS.CREATOR
    config.add_index_field Settings.FIELDS.DESCRIPTION, helper_method: :snippit
    config.add_index_field Settings.FIELDS.PUBLISHER

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # item_prop: [String] property given to span with Schema.org item property
    # link_to_search: [Boolean] that can be passed to link to a facet search
    # helper_method: [Symbol] method that can be used to render the value
    config.add_show_field Settings.FIELDS.CREATOR, label: 'Author(s)', itemprop: 'author', link_to_facet: true
    config.add_show_field Settings.FIELDS.DESCRIPTION, label: 'Description', itemprop: 'description',
                                                       helper_method: :render_value_as_truncate_abstract
    config.add_show_field Settings.FIELDS.PUBLISHER, label: 'Publisher', itemprop: 'publisher'
    config.add_show_field Settings.FIELDS.PART_OF, label: 'Collection', itemprop: 'isPartOf'
    config.add_show_field Settings.FIELDS.SPATIAL_COVERAGE, label: 'Place(s)', itemprop: 'spatial', link_to_facet: true
    config.add_show_field Settings.FIELDS.SUBJECT, label: 'Subject(s)', itemprop: 'keywords', link_to_facet: true
    config.add_show_field Settings.FIELDS.TEMPORAL, label: 'Year', itemprop: 'temporal'
    config.add_show_field Settings.FIELDS.PROVENANCE, label: 'Held by', link_to_facet: true
    config.add_show_field(
      Settings.FIELDS.REFERENCES,
      label: 'More details at',
      accessor: [:external_url],
      if: proc { |_, _, doc| doc.external_url },
      helper_method: :render_references_url
    )

    # config.add_show_field 'dc_title_t', :label => 'Title:'
    # config.add_show_field 'title_display', :label => 'Title:'
    # config.add_show_field 'title_vern_display', :label => 'Title:'
    # config.add_show_field 'subtitle_display', :label => 'Subtitle:'
    # config.add_show_field 'subtitle_vern_display', :label => 'Subtitle:'
    # config.add_show_field 'author_display', :label => 'Author:'
    # config.add_show_field 'author_vern_display', :label => 'Author:'
    # config.add_show_field 'format', :label => 'Format:'
    # config.add_show_field 'url_fulltext_display', :label => 'URL:'
    # config.add_show_field 'url_suppl_display', :label => 'More Information:'
    # config.add_show_field 'language_facet', :label => 'Language:'
    # config.add_show_field 'published_display', :label => 'Published:'
    # config.add_show_field 'published_vern_display', :label => 'Published:'
    # config.add_show_field 'lc_callnum_display', :label => 'Call number:'
    # config.add_show_field 'isbn_t', :label => 'ISBN:'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # config.add_search_field 'text', :label => 'All Fields'
    # config.add_search_field 'dc_title_ti', :label => 'Title'
    # config.add_search_field 'dc_description_ti', :label => 'Description'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    # config.add_search_field('title') do |field|
    #   # solr_parameters hash are sent to Solr as ordinary url query params.
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

    #   # :solr_local_parameters will be sent using Solr LocalParams
    #   # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    #   # Solr parameter de-referencing like $title_qf.
    #   # See: http://wiki.apache.org/solr/LocalParams
    #   field.solr_local_parameters = {
    #     :qf => '$title_qf',
    #     :pf => '$title_pf'
    #   }
    # end

    # config.add_search_field('author') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
    #   field.solr_local_parameters = {
    #     :qf => '$author_qf',
    #     :pf => '$author_pf'
    #   }
    # end

    # # Specifying a :qt only to show it's possible, and so our internal automated
    # # tests can test it. In this case it's the same as
    # # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.qt = 'search'
    #   field.solr_local_parameters = {
    #     :qf => '$subject_qf',
    #     :pf => '$subject_pf'
    #   }
    # end

    #  config.add_search_field('Institution') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'Institution' }
    #   field.solr_local_parameters = {
    #     :qf => '$Institution_qf',
    #     :pf => '$Institution_pf'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, dc_title_sort asc', label: 'relevance'
    config.add_sort_field 'solr_year_i desc, dc_title_sort asc', label: 'year'
    config.add_sort_field 'dc_publisher_sort asc, dc_title_sort asc', label: 'publisher'
    config.add_sort_field 'dc_title_sort asc', label: 'title'
    config.add_sort_field 'layer_modified_dt asc', label: 'Layer modified date (for API use only)', if: false

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Tools from Blacklight
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:citation)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)

    # Custom tools for GeoBlacklight
    # rubocop:disable Layout/LineLength
    config.add_show_tools_partial :web_services, if: proc { |_context, _config, options|
      options[:document] && (Settings.WEBSERVICES_SHOWN & options[:document].references.refs.map { |r| r.type.to_s }).any?
    }
    config.add_show_tools_partial :metadata, if: proc { |_context, _config, options|
      options[:document] && (Settings.METADATA_SHOWN & options[:document].references.refs.map { |r| r.type.to_s }).any?
    }
    config.add_show_tools_partial :arcgis, partial: 'arcgis', if: proc { |_context, _config, options|
      options[:document] && options[:document].arcgis_urls.present?
    }
    # rubocop:enable Layout/LineLength
    config.show.document_actions.delete(:sms)

    # Configure basemap provider
    config.basemap_provider = 'OpenStreetMap.HOT'

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end

  ##
  # Overrides default Blacklight method to return true for an empty q value
  # @return [Boolean]
  def has_search_parameters?
    !params[:q].nil? || super
  end

  def redirect_from_legacy_id
    if (redirect_id = LegacyIdMap.map[params[:id]])
      redirect_to solr_document_path(redirect_id)
    else
      raise Blacklight::Exceptions::RecordNotFound
    end
  end
end
