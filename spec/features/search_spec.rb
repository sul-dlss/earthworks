require 'rails_helper'

describe 'Search' do
  describe 'spelling suggestions' do
    it 'are turned on' do
      visit root_path
      fill_in 'q', with: 'standford'
      click_on 'search'
      expect(page).to have_content 'Did you mean to type:'
    end
  end

  describe 'synonym results' do
    it 'shows synonym results for a specific single word term' do
      visit root_path
      fill_in 'q', with: 'dolphins'
      click_on 'search'
      expect(page).to have_content 'Dolphins are so cool'
      expect(page).to have_content 'Marine mammals are so cool'
    end

    it 'shows synonym results for a multi-word term' do
      visit root_path
      fill_in 'q', with: 'marine mammals'
      click_on 'search'
      expect(page).to have_content 'Dolphins are so cool'
      expect(page).to have_content 'Marine mammals are so cool'
    end
  end
end
