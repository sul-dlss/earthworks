require 'rails_helper'

describe 'Custom facets' do
  describe 'dc_rights_s' do
    it 'handles a query, but not show up in facet bar' do
      visit search_catalog_path(q: '', f: { dc_rights_s: ['Restricted'] })
      expect(page).not_to have_css '.facet-select', text: 'Rights'
      expect(page).to have_css '.filter-name', text: 'Rights'
      expect(page).to have_css '.document', count: 2
    end
  end
end
