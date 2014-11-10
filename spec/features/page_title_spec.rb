require 'rails_helper'

feature 'Main page title' do
  scenario 'should have EarthWorks title' do
    visit root_path
    expect(page.title).to eq 'EarthWorks'
  end
end
