require 'rails_helper'

feature 'Custom featured searches' do
  scenario 'breadcrumbs are present' do
    visit search_catalog_path(q: '', featured: 'geospatial_data')
    expect(page).to have_css '.filterName', text: 'Featured'
    expect(page).to have_css '.filterValue', text: 'Geospatial Data'
  end
end
