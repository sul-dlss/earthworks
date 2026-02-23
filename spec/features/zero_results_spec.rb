require 'rails_helper'

describe 'Zero results' do
  it 'includes feedback text and link' do
    visit search_catalog_path q: 'noresultsXXXX'
    within '.noresults' do
      expect(page).to have_css '.ask-for-dataset'
      expect(page).to have_link 'feedback'
    end
  end
end
