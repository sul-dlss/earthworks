# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  blacklight_config.index.collection_actions.delete(:clear_bookmarks_widget)
end
