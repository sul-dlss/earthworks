require 'rails_helper'

describe 'ODC-ODBL License' do
  it 'renders page without license logo' do
    visit solr_document_path 'stanford-cj936rq6257'
    expect(page).to have_css 'dt', text: 'License'
    expect(page).not_to have_css '.earthworks-license'
  end
end
