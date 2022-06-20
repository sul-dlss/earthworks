require 'rails_helper'

describe 'Author search', feature: true, 'data-integration': true do
  it 'returns 1 result for pinsky' do
    visit root_path
    fill_in 'q', with: 'pinsky'
    click_button 'search'
    expect(page).to have_css '.document', count: 1
    within '.document' do
      # rubocop:disable Layout/LineLength
      expect(page).to have_css 'a',
                               text: 'Abundance Estimates of the Pacific Salmon Conservation Assessment Database, 1978-2008'
      # rubocop:enable Layout/LineLength
    end
  end
end
