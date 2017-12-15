require 'rails_helper'

feature 'Canonical urls' do
  scenario 'Stanford' do
    visit solr_document_path'stanford-cg357zz0321'
    expect(page).to have_css 'link[rel="canonical"]', visible: false
  end
  scenario 'not Stanford' do
    visit solr_document_path'mit-us-ma-e25zcta5dct-2000'
    expect(page).to_not have_css 'link[rel="canonical"]', visible: false
  end
end
