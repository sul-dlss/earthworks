require 'rails_helper'

RSpec.describe CheckLayerJob, skip: 'needs GBLv4 compatibility' do
  context 'when in Solr index' do
    let(:layer) { create(:layer, slug: 'tufts-cambridgegrid100-04', checktype: 'WMS') }

    it 'checks the GeoMonitor::Layer' do
      expect(layer).to receive(:check)
      subject.perform(layer)
    end
  end

  context 'when not in Solr index' do
    let(:layer) { create(:layer) }

    it 'deactivates the GeoMonitor::Layer' do
      expect(layer).not_to receive(:check)
      expect(layer).to receive(:update).with(active: false)
      subject.perform(layer)
    end
  end
end
