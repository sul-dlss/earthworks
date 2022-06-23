require 'rails_helper'

describe 'Customized layout' do
  before do
    visit root_path
  end

  it 'includes the google-site-verification code' do
    expect(page).to have_css("meta[name='google-site-verification'][content='#{Settings.GOOGLE_SITE_VERIFICATION}']",
                             visible: false)
  end
end
