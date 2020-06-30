# frozen_string_literal: true

require 'rails_helper'

feature 'Record view' do
  it 'does not have empty values indexed' do
    visit solr_document_path('columbia-columbia-landinfo-global-aet')

    expect(page).not_to have_css('dt', text: 'Publisher')
  end
end
