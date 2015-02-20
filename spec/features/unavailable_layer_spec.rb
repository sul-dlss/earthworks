require 'rails_helper'

feature 'Unavailable layer' do
  scenario 'hides and shows appropriate messages for geomonitored unavailable' do
    visit catalog_path 'harvard-ntadcd106'
    within '.unavailable-warning' do
      expect(page).to have_content 'Harvard'
      expect(page).to have_content 'unavailable to preview and download'
    end
    expect(page).to_not have_content 'Download Shapefile'
  end
  scenario 'with no downloads shows no download message' do
    visit catalog_path 'princeton-02870w62c'
    within '.unavailable-warning' do
      expect(page).to have_content 'Princeton'
      expect(page).to have_content 'unavailable to download'
    end
  end
end
