require 'rails_helper'

feature 'Custom facets' do
  feature 'dc_rights_s' do
    scenario 'should handle a query, but not show up in facet bar' do
      visit catalog_index_path(q: '', f: { dc_rights_s: ['Restricted'] })
      expect(page).to_not have_css '.facet_select', text: 'Rights'
      expect(page).to have_css '.filterName', text: 'Rights'
      expect(page).to have_css '.document', count: 2
    end
  end
end
