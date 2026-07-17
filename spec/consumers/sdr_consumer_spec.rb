require 'rails_helper'

RSpec.describe SdrConsumer do
  subject(:consumer) do
    described_class.new(
      target: 'earthworks',
      skip_catkey: true,
      cocina_service: cocina_service,
      solr_service: solr_service
    )
  end

  let(:cocina_service) { class_double(CocinaService) }
  let(:solr_service) { class_double(SolrService) }
  let(:record) { instance_double(CocinaDisplay::CocinaRecord, folio_hrid: nil) }
  let(:message) { instance_double(Racecar::Message, key: 'druid:abc123', value: message_contents.to_json) }
  let(:message_contents) { { druid: 'druid:abc123', true_targets: ['Earthworks'] } }

  before do
    allow(Honeybadger).to receive(:notify)
    allow(cocina_service).to receive(:fetch_record).and_return(record)
    allow(solr_service).to receive_messages(delete_by_ids: true, update: true)
  end

  describe '#process_batch' do
    it 'executes an update' do
      expect(solr_service).to receive(:update).with(record)
      consumer.process_batch([message])
    end

    it 'fetches the Cocina record once per message' do
      expect(cocina_service).to receive(:fetch_record).once.and_return(record)
      consumer.process_batch([message])
    end

    context 'with varying spelling of target names' do
      let(:message_contents) { { druid: 'druid:abc123', true_targets: ['EarthWorks'] } }

      it 'counts as valid' do
        expect(solr_service).to receive(:update).with(record)
        consumer.process_batch([message])
      end
    end

    context 'when the kafka message had no content' do
      let(:message_contents) { nil }

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'when the item is unreleased from the target' do
      let(:message_contents) do
        {
          druid: 'druid:abc123',
          false_targets: ['Earthworks']
        }
      end

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'when the item is not released to the target' do
      let(:message_contents) do
        {
          druid: 'druid:abc123',
          true_targets: ['Searchworks']
        }
      end

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'when the item has no public cocina record' do
      before do
        allow(cocina_service).to receive(:fetch_record).and_return(nil)
      end

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'when the record has a catkey' do
      let(:record) { instance_double(CocinaDisplay::CocinaRecord, folio_hrid: 'a12345') }

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'when skip_catkey is false and the record has a catkey' do
      subject(:consumer) do
        described_class.new(
          target: 'earthworks',
          skip_catkey: false,
          cocina_service: cocina_service,
          solr_service: solr_service
        )
      end

      let(:record) { instance_double(CocinaDisplay::CocinaRecord, folio_hrid: 'a12345') }

      it 'executes an update' do
        expect(solr_service).to receive(:update).with(record)
        consumer.process_batch([message])
      end
    end

    context 'when the item is deleted' do
      let(:message_contents) { { druid: 'druid:abc123', deleted_at: '2024-06-02T00:00:00Z' } }

      it 'executes a delete' do
        expect(solr_service).to receive(:delete_by_ids).with(['abc123'])
        consumer.process_batch([message])
      end
    end

    context 'with multiple deletes' do
      it 'deletes them in one Solr request' do
        messages = %w[abc123 def456 ghi789].map do |druid|
          instance_double(Racecar::Message, key: "druid:#{druid}", value: nil)
        end

        expect(solr_service).to receive(:delete_by_ids).with(%w[abc123 def456 ghi789])
        consumer.process_batch(messages)
      end
    end

    context 'when an update occurs between deletes' do
      it 'flushes deletes around the update to preserve order' do
        first_delete = instance_double(Racecar::Message, key: 'druid:abc123', value: nil)
        update = instance_double(Racecar::Message, key: 'druid:def456', value: message_contents.to_json)
        last_delete = instance_double(Racecar::Message, key: 'druid:ghi789', value: nil)

        expect(solr_service).to receive(:delete_by_ids).with(['abc123']).ordered
        expect(solr_service).to receive(:update).with(record).ordered
        expect(solr_service).to receive(:delete_by_ids).with(['ghi789']).ordered

        consumer.process_batch([first_delete, update, last_delete])
      end
    end

    context 'with a blank message after an update' do
      it 'does not reuse the preceding message contents' do
        blank_message = instance_double(Racecar::Message, key: 'druid:def456', value: nil)

        expect(solr_service).to receive(:update).with(record).ordered
        expect(solr_service).to receive(:delete_by_ids).with(['def456']).ordered

        consumer.process_batch([message, blank_message])
      end
    end

    context 'when processing raises an error' do
      before do
        allow(cocina_service).to receive(:fetch_record).and_raise(StandardError, 'Fetch error')
      end

      it 'notifies Honeybadger' do
        expect(Honeybadger).to receive(:notify).with(instance_of(StandardError))
        expect { consumer.process_batch([message]) }.to raise_error(StandardError)
      end
    end
  end
end
