module EarthworksGeoblacklightHelper
  include GeoblacklightHelper

  def document_available?
    (@document.public? && @document.available?) ||
      (@document.same_institution? && user_signed_in? && @document.available?)
  end

  # Override to render multi-valued description as individual paragraphs
  def render_value_as_truncate_abstract(args)
    tag.div class: 'truncate-abstract' do
      Array(args[:value]).flatten.collect { |v| concat tag.p(v) }
    end
  end
end
