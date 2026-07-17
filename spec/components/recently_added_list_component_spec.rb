# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentlyAddedListComponent, type: :component do
  let(:term) { 'Datasets' }
  let(:component) { described_class.new(term:) }
  let(:rendered_component) { render_inline(component) }

  it 'renders the correct number of items by default' do
    expect(rendered_component).to have_css('li', count: 4)
  end

  it 'renders a link to the search results page' do
    expect(rendered_component).to have_link(
      'Browse all datasets',
      href: '/catalog?f%5Bgbl_resourceClass_sm%5D%5B%5D=Datasets&sort=gbl_mdModified_dt+desc'
    )
  end
end
