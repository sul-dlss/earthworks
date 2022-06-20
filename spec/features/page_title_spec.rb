require 'rails_helper'

describe 'Main page title' do
  it 'has EarthWorks title' do
    visit root_path
    expect(page.title).to eq 'EarthWorks'
  end
end

describe 'Search results' do
  it 'have title' do
    visit search_catalog_path q: 'california'
    expect(page.title).to eq 'california - EarthWorks Search Results'
  end
end

describe 'Show page' do
  it 'have title' do
    visit solr_document_path 'stanford-cg357zz0321'
    expect(page.title).to eq '10 Meter Countours: Russian River Basin, California in EarthWorks'
  end
end
