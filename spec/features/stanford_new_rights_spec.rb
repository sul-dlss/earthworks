require 'rails_helper'

feature 'Stanford licenses done the new way' do
  scenario 'renders page with rights information and the license logo' do
    visit solr_document_path'stanford-dy750qs3024'
    expect(page).to have_css 'dt', text: 'License'
    expect(page).to have_link 'This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License', href: 'http://creativecommons.org/licenses/by-nc/3.0/'
    expect(page).to have_css 'dt', text: 'Use and reproduction'
    expect(page).to have_css 'dd', text: 'Image from the Map Collections courtesy Stanford University Libraries. If you have questions, please contact the Branner Earth Science Library & Map Collections at brannerlibrary@stanford.edu.'
    expect(page).to have_css 'dt', text: 'Copyright'
    expect(page).to have_css 'dd', text: 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
  end
end
