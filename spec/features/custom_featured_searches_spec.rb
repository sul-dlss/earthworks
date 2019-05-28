require 'rails_helper'

feature 'Custom featured searches' do
  scenario 'breadcrumbs are present' do
    visit search_catalog_path(q: '', featured: 'geospatial_data')
    expect(page).to have_css '.filter-name', text: 'Featured'
    expect(page).to have_css '.filter-value', text: 'Geospatial Data'
  end
end
