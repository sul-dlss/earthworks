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
    # @return [Array<Blacklight::Solr::Response::Facets::FacetItem>]
    def facet_item_tree_hierarchy_from_year_list
      tree = {}

      @facet_field.paginator.items.each do |item|
        century_str, decade_str, year_str = item.value.split(':')

        tree[century_str] ||= Blacklight::Solr::Response::Facets::FacetItem.new(value: century_str, items: [], hits: 0)

        next unless decade_str

        decade_facet = tree[century_str].items.find do |decade_item|
          decade_item.value == "#{century_str}:#{decade_str}"
        end
        unless decade_facet
          decade_facet = Blacklight::Solr::Response::Facets::FacetItem.new(value: "#{century_str}:#{decade_str}",
                                                                           items: [], hits: 0)
          tree[century_str].items << decade_facet
        end

        next unless year_str

        decade_facet.items << item
        tree[century_str].hits += 1
        decade_facet.hits += 1
      end

      tree.values
    end
  end
end
