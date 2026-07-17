require 'rails_helper'

RSpec.describe SolrService do
  describe '.delete_by_id' do
    let(:connection) { instance_double(RSolr::Client) }

    before do
      allow(described_class).to receive(:connection).and_return(connection)
    end

    it 'deletes with commitWithin instead of explicitly committing' do
      expect(connection).to receive(:delete_by_id)
        .with('stanford-bc123df4567', params: { commitWithin: Settings.solr_commit_within })
      expect(connection).not_to receive(:commit)

      described_class.delete_by_id('bc123df4567')
    end
  end
end
