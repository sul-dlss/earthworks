require 'rails_helper'

describe 'Top Navbar' do
  it 'has links' do
    visit root_path
    within '#topnav' do
      expect(page).to have_link 'Stanford University Libraries'
      expect(page).to have_link 'Login'
      expect(page).to have_link 'Feedback'
    end
  end
end
