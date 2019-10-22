require 'rails_helper'

feature 'Unavailable layer' do
  scenario 'hides and shows appropriate messages for geomonitored unavailable' do
    visit solr_document_path'harvard-ntadcd106'
    within '.unavailable-warning' do
      expect(page).to have_content 'Harvard'
      expect(page).to have_content 'unavailable to preview and download'
    end
    expect(page).to_not have_content 'Download Shapefile'
  end
  scenario 'iiif layer' do
    visit solr_document_path'princeton-02870w62c'
    expect(page).to_not have_content 'unavailable to download'
  end
  scenario 'oembed layer' do
    visit solr_document_path'stanford-dt131hw5005'
    expect(page).to_not have_content 'unavailable to preview and download'
  end
  scenario 'catalog index page should have availablility facets' do
    visit search_catalog_path q: '*'
    expect(page).to have_css '.facet-select', text: 'Unavailable'
    expect(page).to have_css '.facet-select', text: 'Available'
  end
end
