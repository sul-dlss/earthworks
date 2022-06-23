require 'rails_helper'

describe 'Spatial search', feature: true, 'data-integration': true do
  it 'isWithin should be more relevant' do
    visit search_catalog_path(q: 'road', bbox: '61.34 2.11 92 40.45')
    expect(page).to have_css 'h3.index_title', text: '1. Roads: Badakhshān Pr' \
                                                     'ovince, Afghanistan, 2005'
  end
end
