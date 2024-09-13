# frozen_string_literal: true

# Display the date facet in a tree hierarchy
module Blacklight
  class DateFacetHierarchyComponent < Blacklight::FacetFieldListComponent
    def facet_item_presenters
      facet_item_tree_hierarchy_from_year_list.map do |item|
        facet_item_presenter(item)
      end
    end

    private

    # Build out the tree hierarchy (century -> decade -> year) for
    # a facet and return the top-level facet items
    #
    # Input: each item.value is expected to be from a field with hierarchical
    # year info.  There will be an entry for each century covered by the year list,
    # an entry for each decade covered by the year list, and an entry for each year.
    # Each entry has the prefix for its century and (if applicable) decade.  Colon is
    # the delimiter.  So the format is century[:decade[:year]].  E.g. a Solr doc for
    # an object that covers 1996 will have a field that looks like:
    # ["1900-1999", "1900-1999:1990-1999", "1900-1999:1990-1999:1996"]
    # See the date_hierarchy_sm field in this repo's fixture data or in
    # searchworks_traject_indexer for more examples/explanation.
    #
    # Output: The tree that's built is one of nested facet items.  The top level is a list of
    # FacetItem instances, one per century covered.  Each century's #items list has one FacetItem for
    # each decade covered by that century.  And each decade FacetItem#items instance has one entry for each
    # year covered by that decade.  Thus, a tree entry for each element in @facet_field.paginator.items,
    # allowing faceting for each level of the hierarchy.
    #
    # CatalogController uses Blacklight::FacetItemPivotComponent to present a tree
    # node in the facet display for each node in the tree this class builds.
    #
    # @return [Array<Blacklight::Solr::Response::Facets::FacetItem>]
    def facet_item_tree_hierarchy_from_year_list
      tree = {} # a hash mapping each century string (e.g. '1900-1999') to its FacetItem
      top_level = [] # the top-level facet items (centuries)

      @facet_field.paginator.items.each do |item|
        # add the item to the tree at its parent
        *parents, _last = item.value.split(':')
        parent = parents.join(':')
        tree[parent] ||= []
        tree[parent] << item
        tree[item.value] ||= []

        # update the item with its children, if any
        item.items = tree[item.value] if tree[item.value]

        # if this is a century, add it to the top_level array
        top_level << item unless item.value.include?(':')
      end

      top_level
    end
  end
end
