require 'rails_helper'

describe 'Unavailable layer', skip: 'needs GBLv4 compatibility' do
  it 'hides and shows appropriate messages for geomonitored unavailable' do
    visit solr_document_path 'harvard-ntadcd106'
    within '.unavailable-warning' do
      expect(page).to have_content 'Harvard'
      expect(page).to have_content 'unavailable to preview and download'
    end
    expect(page).to have_no_content 'Download Shapefile'
  end

  it 'iiif layer' do
    visit solr_document_path 'princeton-02870w62c'
    expect(page).to have_no_content 'unavailable to download'
  end

  it 'oembed layer' do
    visit solr_document_path 'stanford-dt131hw5005'
    expect(page).to have_no_content 'unavailable to preview and download'
  end

  it 'catalog index page should have availablility facets' do
    visit search_catalog_path q: '*'
    expect(page).to have_css '.facet-select', text: 'Unavailable'
    expect(page).to have_css '.facet-select', text: 'Available'
  end
end
