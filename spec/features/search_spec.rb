require 'rails_helper'

feature 'Search' do
  feature 'spelling suggestions' do
    scenario 'are turned on' do
      visit root_path
      fill_in 'q', with: 'standford'
      click_button 'search'
      expect(page).to have_content 'Did you mean to type:'
    end
  end
end
