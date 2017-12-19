require 'rails_helper'

RSpec.describe CheckLayerJob, type: :job do
  let(:layer) { instance_double(GeoMonitor::Layer, check: []) }
  it 'checks the GeoMonitor::Layer' do
    allow(GeoMonitor::Layer).to receive(:new).and_return(layer)
    subject.perform(layer)
  end
end
