# frozen_string_literal: true

require 'rails_helper'
require 'axe-rspec'

RSpec.describe 'Accessibility testing', :js do
  context 'when logged out' do
    it 'validates the home page' do
      visit root_path
      expect(page).to be_accessible
    end

    it 'validates an item page' do
      visit solr_document_path('tufts-cambridgegrid100-04')
      expect(page).to be_accessible
    end

    # it 'validates an item page with relationships' do
    #   visit solr_document_path('p16022coll205:265')
    #   expect(page).to be_accessible
    # end

    # it 'validates an bookmarks page' do
    #   visit solr_document_path('tufts-cambridgegrid100-04')
    #   find('.checkbox.toggle-bookmark').click
    #   visit bookmarks_path
    #   expect(page).to be_accessible
    # end

    it 'validates the history page' do
      visit '/search_history'
      expect(page).to be_accessible
      visit search_catalog_path({ q: 'index' })
      visit '/search_history'
      expect(page).to be_accessible
    end
  end

  context 'when logged in' do
    let(:user) { create(:user) }
    let(:user_id) { "#{user.sunet_id}@stanford.edu" }

    before do
      login_as(user, scope: :user)
    end

    it 'validates the home page' do
      visit root_path
      expect(page).to be_accessible
    end

    it 'validates an item page' do
      visit solr_document_path('stanford-dp018hs9766')
      expect(page).to be_accessible
    end

    # it 'validates an bookmarks page' do
    #   visit solr_document_path('stanford-dp018hs9766')
    #   find('.checkbox.toggle-bookmark').click
    #   visit '/bookmarks'
    #   expect(page).to be_accessible
    # end
  end

  def be_accessible
    be_axe_clean.excluding('#clover-viewer')
  end
end
