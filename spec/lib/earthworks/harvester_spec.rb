# frozen_string_literal: true

require 'git'
require 'net/http'
require 'earthworks/harvester'
require 'spec_helper'

RSpec.describe Earthworks::Harvester do
  subject(:harvester) { described_class.new(ogm_repos: ogm_repos, ogm_path: ogm_path) }

  let(:ogm_path) { 'tmp/ogm' }
  let(:ogm_repos) do
    {
      'edu.princeton.arks' => { provider: 'Princeton' },
      'edu.psu' => { provider: 'Penn State' }
    }
  end

  let(:stub_repo) { instance_double(Git::Base) }
  let(:stub_gh_api) do
    [
      { name: 'edu.princeton.arks', size: 100 },
      { name: 'edu.psu', size: 100 },
      { name: 'edu.stanford', size: 100 } # not on allowlist (we don't harvest ourselves)
    ]
  end

  before do
    # stub github API requests
    # use the whole org response, or just a portion for particular repos
    allow(Net::HTTP).to receive(:get) do |uri|
      if uri == described_class.ogm_api_uri
        stub_gh_api.to_json
      else
        repo_name = uri.path.split('/').last.gsub('.git', '')
        stub_gh_api.find { |repo| repo[:name] == repo_name }.to_json
      end
    end

    # stub git commands
    allow(Git).to receive_messages(open: stub_repo, clone: stub_repo)
    allow(stub_repo).to receive(:pull).and_return(stub_repo)
  end

  describe '#clone' do
    it 'clones only repositories configured in settings' do
      expect(Git).to receive(:clone).twice
      expect(Git).not_to receive(:clone).with('https://github.com/OpenGeoMetadata/edu.stanford.git')
      harvester.clone_all
    end
  end

  describe '#pull' do
    it 'pulls only repositories configured in settings' do
      expect(stub_repo).to receive(:pull).twice
      expect(stub_repo).not_to receive(:pull).with('edu.stanford')
      harvester.pull_all
    end
  end

  describe '#docs_to_index' do
    # Provenance value will be transformed by our ogm_repos config
    let(:psu_doc) { { schema_provider_s: 'Pennsylvania State University', geoblacklight_version: '1.0' }.to_json }
    let(:psu_path) { "#{ogm_path}/edu.psu/metadata-1.0/Maps/08d-01/geoblacklight.json" }

    # PolicyMap records have placeholder data and should be skipped
    let(:policymap_doc) { { schema_provider_s: 'Geoblacklight', geoblacklight_version: '1.0' }.to_json }
    let(:policymap_path) { "#{ogm_path}/shared-repository/gbl-policymap/records/geoblacklight.json" }

    before do
      allow(Find).to receive(:find).and_yield(psu_path).and_yield(policymap_path)
      allow(File).to receive(:read).with(psu_path).and_return(psu_doc)
      allow(File).to receive(:read).with(policymap_path).and_return(policymap_doc)
    end

    it 'supports skipping arbitrary records' do
      docs = harvester.docs_to_index.to_a
      expect(docs.length).to eq(1)
      expect(docs.first.last).to eq(psu_path)
    end

    it 'supports transforming arbitrary records' do
      docs = harvester.docs_to_index.to_a
      expect(docs.first.first['schema_provider_s']).to eq('Penn State')
    end
  end
end
