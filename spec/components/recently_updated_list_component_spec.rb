# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentlyUpdatedListComponent, type: :component do
  let(:term) { 'Datasets' }
  let(:component) { described_class.new(response:, term:) }
  let(:rendered_component) { render_inline(component) }
  let(:response) do
    Blacklight::Solr::Response.new(
      { 'response' => { 'numFound' => 1234, 'docs' => docs } },
      {},
      blacklight_config: CatalogController.blacklight_config
    )
  end
  let(:docs) do
    [
      { 'id' => 'stanford-abc123', 'dct_title_s' => 'First dataset' },
      { 'id' => 'stanford-def456', 'dct_title_s' => 'Second dataset' }
    ]
  end

  it 'renders a link to each document' do
    expect(rendered_component).to have_css('li', count: 2)
    expect(rendered_component).to have_link('First dataset', href: '/catalog/stanford-abc123')
    expect(rendered_component).to have_link('Second dataset', href: '/catalog/stanford-def456')
  end

  it 'renders the total number of items' do
    expect(rendered_component).to have_text('There are 1,234 datasets in EarthWorks.')
  end

  it 'renders a link to the search results page' do
    expect(rendered_component).to have_link(
      'Browse all datasets',
      href: '/catalog?f%5Bgbl_resourceClass_sm%5D%5B%5D=Datasets&sort=gbl_mdModified_dt+desc'
    )
  end
end
