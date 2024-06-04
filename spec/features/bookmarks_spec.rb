require 'rails_helper'

describe 'Blacklight Bookmarks' do
  it 'index has created bookmarks' do
    skip('Passes locally, not on Travis.') if ENV['CI']
    visit solr_document_path 'columbia-columbia-landinfo-global-aet'
    click_on 'Bookmark'
    visit bookmarks_path
    expect(page).to have_css '.document', count: 1
  end
end
