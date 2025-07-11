require 'blacklight/catalog'

class CatalogController < ApplicationController
  include Blacklight::Catalog

  # Protect searches with bot_challenge_page & turnstile
  # See: https://github.com/samvera-labs/bot_challenge_page
  #
  # We protect requests for searches, but not for show pages, so we can still
  # crawl ourselves and let well-behaved search engines index our content via
  # the sitemap.
  before_action only: :index do |controller|
    BotChallengePage::BotChallengePageController.bot_challenge_enforce_filter(controller, immediate: true)

    # Additional fields needed for Bento
    if request.format.json?
      blacklight_config.add_index_field Settings.FIELDS.RESOURCE_CLASS, helper_method: :get_specific_field_type
      blacklight_config.add_index_field Settings.FIELDS.SPATIAL_COVERAGE
      blacklight_config.index_fields.each_value { |v| v.if = true }
    end
  end

  configure_blacklight do |config|
    # Ensures that JSON representations of Solr Documents can be retrieved using
    # the path /catalog/:id/raw
    # Please see https://github.com/projectblacklight/blacklight/pull/2006/
    config.raw_endpoint.enabled = true

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :start => 0,
      :rows => 20,
      'q.alt' => '*:*'
    }

    config.default_per_page = 20
    # Default parameters to send on single-document requests to Solr.
    # These settings are the Blacklight defaults (see SolrHelper#solr_doc_params) or
    # parameters included in the Blacklight-jetty document requestHandler.
    config.default_document_solr_params = {
      qt: 'document',
      q: "{!raw f=#{Settings.FIELDS.ID} v=$id}"
    }

    # When set to true, Blacklight uses container-fluid as the layout container
    config.full_width_layout = true

    # GeoBlacklight Defaults
    # * Adds the "map" split view for catalog#index
    config.view.split(partials: ['index'])
    config.view.delete_field('list')

    config.index.dropdown_component = DropdownComponent

    # solr field configuration for search results/index views
    # config.index.show_link = 'title_display'
    # config.index.record_display_type = 'format'

    config.index.document_component = SearchResultComponent
    config.index.title_field = Settings.FIELDS.TITLE
    config.index.search_bar_component = SearchBarComponent
    config.index.facet_group_component = FacetGroupComponent

    config.bookmark_icon_component = Blacklight::Icons::BookmarkIconComponent

    config.track_search_session.applied_params_component = SearchContext::ServerAppliedParamsComponent
    config.index.constraints_component = ConstraintsComponent

    config.crawler_detector = ->(req) { req.env['HTTP_USER_AGENT']&.include?('bot') }

    # solr field configuration for document/show views
    config.show.display_type_field = 'format'

    config.show.sidebar_component = Document::SidebarComponent
    config.show.document_component = DocumentComponent
    config.show.metadata_component = DocumentMetadataComponent
    config.header_component = Geoblacklight::HeaderComponent

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

    # DEFAULT FACETS
    # to add additional facets, use the keys defined in the settings.yml file
    config.add_facet_field Settings.FIELDS.RESOURCE_CLASS, label: 'Resource Class', limit: 8,
                                                           item_component: Geoblacklight::IconFacetItemComponent
    config.add_facet_field Settings.FIELDS.RESOURCE_TYPE, label: 'Genre/Data Type', limit: 8
    config.add_facet_field Settings.FIELDS.THEME, label: 'Theme', limit: 8
    config.add_facet_field Settings.FIELDS.SPATIAL_COVERAGE, label: 'Location', limit: 8

    config.add_facet_field Settings.FIELDS.HIERARCHICAL_INDEX_YEAR, label: 'Date', limit: -1, sort: :index,
                                                                    collapsing: true, single: true,
                                                                    component: Blacklight::DateFacetHierarchyComponent,
                                                                    item_component: Blacklight::FacetItemPivotComponent,
                                                                    item_presenter: DateFacetItemPresenter

    config.add_facet_field Settings.FIELDS.CREATOR, label: 'Author', limit: 8
    config.add_facet_field Settings.FIELDS.PUBLISHER, label: 'Publisher', limit: 8
    config.add_facet_field Settings.FIELDS.PROVIDER, label: 'Provider', limit: 8,
                                                     item_component: Geoblacklight::IconFacetItemComponent
    config.add_facet_field Settings.FIELDS.ACCESS_RIGHTS, label: 'Access', limit: 8,
                                                          item_component: Geoblacklight::IconFacetItemComponent
    # Disabled until GeoMonitor is updated for v4.x compatibility
    # https://github.com/geoblacklight/geo_monitor/issues/12
    # config.add_facet_field 'availability',
    #                        label: 'Availability',
    #                        query: {
    #                          available: {
    #                            label: 'Available',
    #                            fq: "(layer_availability_score_f:[#{Settings.GEOMONITOR_TOLERANCE} TO 1])"
    #                          },
    #                          unavailable: {
    #                            label: 'Unavailable',
    #                            fq: "layer_availability_score_f:[0 TO #{Settings.GEOMONITOR_TOLERANCE}]"
    #                          }
    #                        },
    #                        item_component: Geoblacklight::IconFacetItemComponent

    # GEOBLACKLIGHT APPLICATION FACETS

    # Map-Based "Search Here" Feature
    # item_presenter       - Defines how the facet appears in the GBL UI
    # filter_query_builder - Defines the query generated for Solr
    # filter_class         - Defines how to add/remove facet from query
    # label                - Defines the label used in contstraints container
    config.add_facet_field Settings.FIELDS.GEOMETRY,
                           item_presenter: Geoblacklight::BboxItemPresenter,
                           filter_class: Geoblacklight::BboxFilterField,
                           filter_query_builder: Geoblacklight::BboxFilterQuery,
                           within_boost: Settings.BBOX_WITHIN_BOOST,
                           overlap_boost: Settings.OVERLAP_RATIO_BOOST,
                           overlap_field: Settings.FIELDS.OVERLAP_FIELD,
                           label: 'Bounding Box'

    # Item Relationship Facets
    # * Not displayed to end user (show: false)
    # * Must be present for relationship "Browse all 4 records" links to work
    # * Label value becomes the search contraint filter name
    config.add_facet_field Settings.FIELDS.MEMBER_OF, label: 'Member Of', show: false
    config.add_facet_field Settings.FIELDS.IS_PART_OF, label: 'Is Part Of', show: false
    config.add_facet_field Settings.FIELDS.RELATION, label: 'Related', show: false
    config.add_facet_field Settings.FIELDS.REPLACES, label: 'Replaces', show: false
    config.add_facet_field Settings.FIELDS.IS_REPLACED_BY, label: 'Is Replaced By', show: false
    config.add_facet_field Settings.FIELDS.SOURCE, label: 'Source', show: false
    config.add_facet_field Settings.FIELDS.VERSION, label: 'Is Version Of', show: false
    config.add_facet_field Settings.FIELDS.SUBJECT, label: 'Subject', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # SEARCH RESULTS FIELDS
    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field Settings.FIELDS.INDEX_YEAR
    config.add_index_field Settings.FIELDS.CREATOR
    config.add_index_field Settings.FIELDS.DESCRIPTION, helper_method: :snippit
    config.add_index_field Settings.FIELDS.PUBLISHER

    # ITEM VIEW FIELDS
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # item_prop: [String] property given to span with Schema.org item property
    # link_to_search: [Boolean] that can be passed to link to a facet search
    # helper_method: [Symbol] method that can be used to render the value
    config.add_show_field Settings.FIELDS.CREATOR, label: 'Creator', itemprop: 'creator', link_to_facet: true
    config.add_show_field Settings.FIELDS.DESCRIPTION, label: 'Description', itemprop: 'description',
                                                       helper_method: :render_value_as_truncate_abstract
    config.add_show_field Settings.FIELDS.PUBLISHER, label: 'Publisher', itemprop: 'publisher', link_to_facet: true
    config.add_show_field Settings.FIELDS.SPATIAL_COVERAGE, label: 'Place', itemprop: 'spatial',
                                                            link_to_facet: true
    config.add_show_field Settings.FIELDS.SUBJECT, label: 'Subject', itemprop: 'keywords', link_to_facet: true
    config.add_show_field Settings.FIELDS.THEME, label: 'Theme', itemprop: 'theme', link_to_facet: true
    config.add_show_field Settings.FIELDS.DATE_ISSUED, label: 'Date Issued', itemprop: 'issued'
    config.add_show_field Settings.FIELDS.TEMPORAL_COVERAGE, label: 'Temporal Coverage', itemprop: 'temporal'
    config.add_show_field Settings.FIELDS.PROVIDER, label: 'Provider', link_to_facet: true
    config.add_show_field Settings.FIELDS.RESOURCE_CLASS, label: 'Resource Class', itemprop: 'class',
                                                          link_to_facet: true
    config.add_show_field Settings.FIELDS.RESOURCE_TYPE, label: 'Resource Type', itemprop: 'type', link_to_facet: true
    # config.add_show_field Settings.FIELDS.FORMAT, label: 'Format', itemprop: 'format'
    config.add_show_field Settings.FIELDS.RIGHTS, label: 'Use and Reproduction', itemprop: 'rights'
    config.add_show_field Settings.FIELDS.RIGHTS_HOLDER, label: 'Copyright', itemprop: 'rights_holder'
    config.add_show_field Settings.FIELDS.LICENSE, label: 'License', itemprop: 'license', helper_method: :render_license
    config.add_show_field(
      Settings.FIELDS.IDENTIFIER,
      label: 'More details at',
      accessor: [:external_links],
      if: proc { |_, _, doc| doc.external_links.any? },
      helper_method: :render_details_links
    )

    # ADDITIONAL FIELDS
    # The following fields are not user friendly and are not set to appear on the item show page.
    # They contain non-literal values, codes, URIs, or are otherwise designed to power features in the interface.
    # These values might need a translations to be readable by users.

    # config.add_show_field Settings.FIELDS.LANGUAGE, label: 'Language', itemprop: 'language'
    # config.add_show_field Settings.FIELDS.KEYWORD, label: 'Keyword(s)', itemprop: 'keyword'

    # config.add_show_field Settings.FIELDS.INDEX_YEAR, label: 'Year', itemprop: 'year'
    # config.add_show_field Settings.FIELDS.DATE_RANGE, label: 'Date Range', itemprop: 'date_range'

    # config.add_show_field Settings.FIELDS.CENTROID, label: 'Centroid', itemprop: 'centroid'
    # config.add_show_field Settings.FIELDS.OVERLAP_FIELD, label: 'Overlap BBox', itemprop: 'overlap_field'

    # config.add_show_field Settings.FIELDS.RELATION, label: 'Relation', itemprop: 'relation'
    # config.add_show_field Settings.FIELDS.MEMBER_OF, label: 'Member Of', itemprop: 'member_of'
    # config.add_show_field Settings.FIELDS.IS_PART_OF, label: 'Is Part Of', itemprop: 'is_part_of'
    # config.add_show_field Settings.FIELDS.VERSION, label: 'Version', itemprop: 'version'
    # config.add_show_field Settings.FIELDS.REPLACES, label: 'Replaces', itemprop: 'replaces'
    # config.add_show_field Settings.FIELDS.IS_REPLACED_BY, label: 'Is Replaced By', itemprop: 'is_replaced_by'

    # config.add_show_field Settings.FIELDS.WXS_IDENTIFIER, label: 'Web Service Layer', itemprop: 'wxs_identifier'
    # config.add_show_field Settings.FIELDS.ID, label: 'ID', itemprop: 'id'
    # config.add_show_field Settings.FIELDS.IDENTIFIER, label: 'Identifier', itemprop: 'identifier'

    # config.add_show_field Settings.FIELDS.MODIFIED, label: 'Date Modified', itemprop: 'modified'
    # config.add_show_field Settings.FIELDS.METADATA_VERSION, label: 'Metadata Version', itemprop: 'metadata_version'
    # config.add_show_field Settings.FIELDS.SUPPRESSED, label: 'Suppressed', itemprop: 'suppresed'

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

    config.add_search_field 'all_fields', label: 'All Fields'
    # config.add_search_field 'text', :label => 'All Fields'
    # config.add_search_field 'dct_title_ti', :label => 'Title'
    # config.add_search_field 'dct_description_ti', :label => 'Description'

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
    config.add_sort_field 'score desc, dct_title_sort asc', label: 'relevance'
    config.add_sort_field "#{Settings.FIELDS.INDEX_YEAR} desc, dct_title_sort asc", label: 'year'
    config.add_sort_field 'dct_title_sort asc', label: 'title'
    config.add_sort_field "#{Settings.FIELDS.MODIFIED} asc", label: 'Layer modified date (for API use only)', if: false

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Nav actions from Blacklight
    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent,
                                                if: :render_bookmarks_control?)

    # Tools from Blacklight
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_show_header_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent,
                                                    if: :render_bookmarks_control?)
    config.add_show_header_tools_partial(:citation)
    config.add_show_header_tools_partial(:email, callback: :email_action, validator: :validate_email_params)

    # Custom tools for GeoBlacklight
    config.add_show_tools_partial :metadata, if: proc { |_context, _config, options|
                                                   options[:document] &&
                                                     (Settings.METADATA_SHOWN &
                                                      options[:document].references.refs.map { |x| x.type.to_s }).any?
                                                 }
    config.add_show_tools_partial :code_snippet_link, component: CodeSnippetLinkComponent,
                                                      if: proc { |_context, _config, options|
                                                        options[:document]&.dataset? &&
                                                          !options[:document].restricted?
                                                      }
    config.show.document_actions.delete(:sms)

    config.add_show_header_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_header_tools_partial(:citation)
    config.add_show_header_tools_partial(:email, callback: :email_action, validator: :validate_email_params)

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end

  def web_services
    @docs = action_documents

    respond_to do |format|
      format.html do
        return render layout: false if request.xhr?
        # Otherwise draw the full page
      end
    end
  end

  # Adding code snippet function, uses code_snippet.html.erb partial
  def code_snippet
    @docs = action_documents

    respond_to do |format|
      format.html do
        return render layout: false if request.xhr?
        # Otherwise draw the full page
      end
    end
  end
end
