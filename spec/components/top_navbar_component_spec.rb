require 'rails_helper'

RSpec.describe TopNavbarComponent, type: :component do
  let(:component) { described_class.new(blacklight_config: Blacklight::Configuration.new) }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(User.new)
    render_inline(component)
  end

  it 'has links' do
    expect(page).to have_link 'Stanford University'
    expect(page).to have_link 'Login'
    expect(page).to have_link 'Feedback'
  end
end
