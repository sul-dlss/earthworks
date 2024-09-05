# frozen_string_literal: true

class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
  # Overriding to remove dl-invert as a default class
  def initialize(fields: [], classes: %w[document-metadata row su-underline], **)
    super
  end
end
