require 'rails_helper'

describe 'Canonical urls' do
  it 'Stanford' do
    visit solr_document_path 'stanford-cg357zz0321'
    expect(page).to have_css 'link[rel="canonical"]', visible: false
  end

  it 'not Stanford' do
    visit solr_document_path 'mit-us-ma-e25zcta5dct-2000'
    expect(page).not_to have_css 'link[rel="canonical"]', visible: false
  end
end
