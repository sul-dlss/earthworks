require 'rails_helper'

feature 'Main page title' do
  scenario 'should have EarthWorks title' do
    visit root_path
    expect(page.title).to eq 'EarthWorks'
  end
end
feature 'Search results' do
  scenario 'have title' do
    visit search_catalog_path q: 'california'
    expect(page.title).to eq 'Keywords: california - EarthWorks Search Results'
  end
end
feature 'Show page' do
  scenario 'have title' do
    visit solr_document_path'stanford-cg357zz0321'
    expect(page.title).to eq '10 Meter Countours: Russian River Basin, California in EarthWorks'
  end
end
