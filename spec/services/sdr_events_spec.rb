require 'rails_helper'

RSpec.describe SdrEvents do
  describe '.configure' do
    it 'configures the event client' do
      expect(Dor::Event::Client).to receive(:configure).with(
        hostname: 'localhost',
        vhost: '/',
        username: 'guest',
        password: 'guest'
      )

      described_class.configure
    end
  end

  describe '.report_indexing_success' do
    before do
      allow(described_class).to receive(:enabled?).and_return(enabled)
    end

    context 'when event reporting is enabled' do
      let(:enabled) { true }

      it 'publishes an indexing success event' do
        allow(Socket).to receive(:gethostname).and_return('indexer.example.com')
        expect(Dor::Event::Client).to receive(:create).with(
          druid: 'druid:abc123',
          type: 'earthworks_indexing_success',
          data: {
            target: 'earthworks',
            host: 'indexer.example.com',
            invoked_by: 'publish_event'
          }
        )

        described_class.report_indexing_success('abc123', target: 'earthworks')
      end
    end

    context 'when event reporting is disabled' do
      let(:enabled) { false }

      it 'does not publish an event' do
        expect(Dor::Event::Client).not_to receive(:create)
        described_class.report_indexing_success('abc123', target: 'earthworks')
      end
    end
  end
end
