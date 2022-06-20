require 'rails_helper'

describe 'Custom featured searches' do
  it 'breadcrumbs are present' do
    visit search_catalog_path(q: '', featured: 'geospatial_data')
    expect(page).to have_css '.filter-name', text: 'Featured'
    expect(page).to have_css '.filter-value', text: 'Geospatial Data'
  end
end
