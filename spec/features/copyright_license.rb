require 'rails_helper'

feature 'Use and reproduction, copyright and license' do
  scenario 'Stanford restricted' do
    visit solr_document_path'stanford-cg357zz0321'
    expect(page).to have_css 'dt', text: 'Use and reproduction'
    expect(page).to have_css 'dd', text: 'These data are licensed by Stanford Libraries and are available to Stanford University affiliates only. Affiliates are limited to current faculty, staff and students. These data may not be reproduced or used for any purpose without permission. For more information please contact brannerlibrary@stanford.edu.'
    expect(page).to have_css 'dt', text: 'Copyright'
    expect(page).to have_css 'dd', text: 'Copyright ownership resides with the originator.'
  end
  scenario 'Stanford public' do
    visit solr_document_path'stanford-cz128vq0535'
    expect(page).to have_css 'dt', text: 'Use and reproduction'
    expect(page).to have_css 'dd', text: 'This item is in the public domain. There are no restrictions on use.'
    expect(page).to have_css 'dt', text: 'Copyright'
    expect(page).to have_css 'dd', text: 'This work is in the Public Domain, meaning that it is not subject to copyright.'
    expect(page).to have_css 'dt', text: 'License'
    expect(page).to have_css 'dd', text: 'Attribution Share Alike 3.0 Unported'
  end
end
