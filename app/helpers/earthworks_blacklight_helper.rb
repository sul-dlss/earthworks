module EarthworksBlacklightHelper
  include Blacklight::LayoutHelperBehavior
  def show_content_classes
    'col-lg-5 show-document'
  end

  def show_sidebar_classes
    'page-sidebar col-lg-2'
  end
end
