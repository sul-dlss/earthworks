module EarthworksBlacklightHelper
  include Blacklight::LayoutHelperBehavior
  def show_content_classes
    'col-lg-10 show-document row'
  end

  def show_sidebar_classes
    'page-sidebar col-lg-2'
  end

  def render_details_links(args)
    tag.ul class: 'list-unstyled' do
      args[:document].identifiers.collect { |identifier| concat tag.li(link_to(identifier, identifier)) }
    end
  end
end
