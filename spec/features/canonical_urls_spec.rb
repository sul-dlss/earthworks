require 'rails_helper'

describe 'Canonical urls' do
  it 'Stanford' do
    visit solr_document_path 'stanford-cg357zz0321'
    expect(page).to have_css 'link[rel="canonical"]', visible: false
  end

  it 'not Stanford' do
    visit solr_document_path 'princeton-02870w62c'
    expect(page).to have_content 'The provinces of New York and New Jersey'
    expect(page).to have_no_css 'link[rel="canonical"]', visible: false
  end
end
