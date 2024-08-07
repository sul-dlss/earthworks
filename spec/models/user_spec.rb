# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'guests_without_bookmarks scope' do
    let!(:guest_user_with_bookmarks) { create(:user, guest: true) }
    let!(:non_guest_user) { create(:user, guest: false) }

    before do
      Bookmark.create(document: SolrDocument.new('stanford-abc123'), user: guest_user_with_bookmarks)
      create_list(:user, 10, guest: true)
    end

    it 'does not include non-guest users' do
      expect(User.guests_without_bookmarks.pluck(:id)).not_to include(non_guest_user.id)
    end

    it 'does not include guest users who have bookmarks' do
      expect(User.guests_without_bookmarks.pluck(:id)).not_to include(guest_user_with_bookmarks.id)
    end

    it 'includes guest users who do not have bookmarks' do
      expect(User.count).to be 12
      expect(User.guests_without_bookmarks.count).to be 10
    end
  end

  describe '#sunet' do
    it 'returns just the SUNet part of the email address' do
      expect(User.new(email: 'jstanford@stanford.edu').sunet).to eq 'jstanford'
    end
  end

  describe '#shibboleth_groups=' do
    subject(:user) { User.new }

    it 'splits groups on the pipe character' do
      user.shibboleth_groups = 'a;b;c'
      expect(user.shibboleth_groups).to match_array %w[a b c]
    end
  end
end
