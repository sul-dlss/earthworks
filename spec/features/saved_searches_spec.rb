require 'spec_helper'

feature 'Saved searches' do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  scenario 'test' do
    visit catalog_index_path q: '*'
    click_button 'Save this search'
    visit saved_searches_path
    expect(page).to have_css 'td', count: 2 #Saved searches are stored in a table
  end
end
