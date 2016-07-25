require 'rails_helper'

feature 'Zero results' do
  scenario 'includes feedback text and link' do
    visit search_catalog_path q: 'xyz'
    within '.noresults' do
      expect(page).to have_css '.ask-for-dataset'
      expect(page).to have_css 'a', text: 'feedback'
    end
  end
end
