require 'rails_helper'

feature 'Open in CartoDB' do
  scenario 'item is available' do
    visit catalog_path 'stanford-cz128vq0535'
    expect(page).to have_css 'li.exports a'
  end
  scenario 'item is not available' do
    visit catalog_path 'harvard-ntadcd106'
    expect(page).to_not have_css 'li.exports a'
  end
end
