require 'rails_helper'

describe 'Open in CartoDB' do
  it 'item is available' do
    visit solr_document_path 'stanford-cz128vq0535'
    expect(page).to have_css 'li.carto a'
  end

  it 'item is not available' do
    visit solr_document_path 'harvard-ntadcd106'
    expect(page).not_to have_css 'li.carto a'
  end
end
