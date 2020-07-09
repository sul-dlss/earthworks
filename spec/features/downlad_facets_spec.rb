require 'rails_helper'

feature 'Download as facets' do
  scenario 'correct download as types' do
    visit catalog_index_path q: '*'
    within '#facet-download-as' do
      expect(page).to have_css 'li', text: 'Shapefile5'
      expect(page).to have_css 'li', text: 'KMZ5'
      expect(page).to have_css 'li', text: 'GeoJSON5'
      expect(page).to have_css 'li', text: 'GeoTIFF3'
      expect(page).to have_css 'li', text: 'ArcGRID1'
    end
  end
end
