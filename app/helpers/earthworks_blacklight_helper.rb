module EarthworksBlacklightHelper
  include Blacklight::LayoutHelperBehavior
  # Blacklight override for show main content
  def show_content_classes
    'col-lg-10 show-document row'
  end

  # Blacklight override for show page sidebar
  def show_sidebar_classes
    'page-sidebar col-lg-2'
  end

  # Blacklight override for search results
  def main_content_classes
    'col-md-9 col-lg-10'
  end

  # Blacklight override for search result facets
  def sidebar_classes
    'page-sidebar col-md-3 col-lg-2 order-md-1'
  end

  def render_details_links(args)
    tag.ul class: 'list-unstyled' do
      args[:document].external_links.collect { |url| concat tag.li(link_to(url, url)) }
    end
  end
end
