# frozen_string_literal: true

class DocumentComponent < Geoblacklight::DocumentComponent
  def classes
    [
      @classes,
      helpers.render_document_class(@document),
      'document',
      'col-lg-6',
      ("document-position-#{@counter}" if @counter)
    ].compact.flatten
  end
end
