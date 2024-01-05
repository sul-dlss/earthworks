require 'rails_helper'

describe 'Feedback form (js)', js: true do
  before do
    visit root_path
  end

  it 'feedback form should be hidden' do
    expect(page).to have_no_css('#feedback-form', visible: true)
  end

  it 'feedback form should be shown filled out and submitted' do
    click_link 'Feedback'
    skip('Passes locally, not on Travis.') if ENV['CI']
    expect(page).to have_css('#feedback-form', visible: true)
    expect(page).to have_button('Cancel')
    within 'form.feedback-form' do
      fill_in('message', with: 'This is only a test')
      fill_in('name', with: 'Ronald McDonald')
      fill_in('to', with: 'test@kittenz.eu')
      click_button 'Send'
    end
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end

describe 'Feedback form (no js)' do
  before do
    visit root_path
  end

  it 'feedback form should be shown filled out and submitted' do
    click_link 'Feedback'
    expect(page).to have_css('#feedback-form', visible: true)
    expect(page).to have_link('Cancel')
    within 'form.feedback-form' do
      fill_in('message', with: 'This is only a test')
      fill_in('name', with: 'Ronald McDonald')
      fill_in('to', with: 'test@kittenz.eu')
      click_button 'Send'
    end
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end
