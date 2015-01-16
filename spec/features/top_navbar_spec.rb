require 'rails_helper'

feature 'Top Navbar' do
  scenario 'has links' do
    visit root_path
    within '#topnav' do
      expect(page).to have_link 'Stanford University Libraries'
      expect(page).to have_link 'Login'
      expect(page).to have_link 'Feedback'
    end
  end
end
