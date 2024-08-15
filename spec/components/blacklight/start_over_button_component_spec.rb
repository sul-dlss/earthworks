# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::StartOverButtonComponent, type: :component do
  subject(:render) { render_inline(component) }

  let(:component) { described_class.new }

  it 'renders a start over button' do
    render
    # We override core Blacklight components to always set the search_field to 'all_fields'
    expect(component.call).to include('href="/catalog?search_field=all_fields"')
    expect(component.call).to include('Start Over')
  end
end
