require 'rails_helper'

describe 'Hierarchical date facet' do
  before do
    visit root_path
    click_link_or_button 'search'
  end

  it 'includes an expandable date facet' do
    expect(page).to have_content('1 - 18 of 18')

    click_link_or_button 'Date'
    expect(page).to have_link('1900-1999', visible: :visible)

    find_link('1900-1999').ancestor('li.treeitem').first(:button).click
    expect(page).to have_content('1 - 18 of 18') # have only expanded the facet for 1900s, haven't filtered yet
    expect(page).to have_css('li.treeitem ul li.treeitem', text: /1990-1999/, visible: :visible)
    click_link_or_button '1990-1999'
    expect(page).to have_content('1 - 3 of 3')
    expect(page).to have_content('106th Congressional District Boundaries')
    expect(page).to have_content('tectonic map of Britain, Ireland and adjacent areas / British Geological Survey')
    expect(page).to have_content('Actual Evapotrans')
  end
end
