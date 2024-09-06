class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Geoblacklight::SuppressedRecordsSearchBehavior
end
