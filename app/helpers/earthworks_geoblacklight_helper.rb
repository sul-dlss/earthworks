module EarthworksGeoblacklightHelper
  include GeoblacklightHelper

  # Override to render multi-valued description as individual paragraphs
  def render_value_as_truncate_abstract(args)
    tag.div class: 'truncate-abstract' do
      Array(args[:value]).flatten.collect { |v| concat tag.p(v) }
    end
  end
end
