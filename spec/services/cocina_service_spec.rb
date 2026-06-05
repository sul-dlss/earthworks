require 'rails_helper'

RSpec.describe CocinaService do
  let(:druid) { 'bc123df4567' }
  let(:purl_url) { "https://purl.stanford.edu/#{druid}.json" }
  let(:cocina_json) do
    {
      'externalIdentifier' => "druid:#{druid}",
      'type' => 'http://cocina.sul.stanford.edu/models/image.json',
      'label' => 'Test Record',
      'version' => 1
    }.to_json
  end

  describe '.fetch_record' do
    context 'when the request is successful' do
      before do
        stub_request(:get, purl_url)
          .to_return(status: 200, body: cocina_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a CocinaRecord object' do
        record = described_class.fetch_record(druid)
        expect(record).to be_a(CocinaDisplay::CocinaRecord)
        expect(record.druid).to eq("druid:#{druid}")
      end
    end

    context 'when the request is not found' do
      before do
        stub_request(:get, purl_url)
          .to_return(status: 404)
      end

      it 'returns nil' do
        expect(described_class.fetch_record(druid)).to be_nil
      end
    end

    context 'when there is an error' do
      before do
        stub_request(:get, purl_url)
          .to_raise(StandardError.new('Some error'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Error fetching cocina record for #{druid}: Some error/)
        expect(described_class.fetch_record(druid)).to be_nil
      end
    end
  end
end
