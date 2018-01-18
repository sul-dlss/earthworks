require 'rails_helper'

feature 'ODC-ODBL License' do
  scenario 'renders page without license logo' do
    visit solr_document_path'stanford-cj936rq6257'
    expect(page).to have_css 'dt', text: 'License'
    expect(page).to_not have_css '.earthworks-license'
  end
end
