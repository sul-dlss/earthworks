require 'rails_helper'

feature 'Unavailable layer' do
  scenario 'hides and shows appropriate messages' do
    visit catalog_path 'harvard-ntadcd106'
    within '.unavailable-warning' do
      expect(page).to have_content 'Harvard'
    end
    expect(page).to_not have_content 'Download Shapefile'
  end
end
