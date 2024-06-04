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
end
