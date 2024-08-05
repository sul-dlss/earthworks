require 'rails_helper'

describe 'Top Navbar' do
  it 'has links' do
    visit root_path
    within 'header' do
      expect(page).to have_link 'Stanford University'
      expect(page).to have_link 'Login'
      expect(page).to have_link 'Feedback'
    end
  end
end
