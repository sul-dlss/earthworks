# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentlyAddedListComponent, type: :component do
  let(:term) { 'Datasets' }
  let(:component) { described_class.new(term:) }
  let(:rendered_component) { render_inline(component) }

  it 'renders the correct number of items by default' do
    expect(rendered_component).to have_css('li', count: 4)
  end
end
