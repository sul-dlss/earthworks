# frozen_string_literal: true

require 'git'
require 'net/http'
require 'earthworks/harvester'
require 'spec_helper'
require 'rails_helper'

RSpec.describe Earthworks::Harvester do
  subject(:harvester) { described_class.new(ogm_repos:, ogm_path:, schema_version: 'Aardvark') }

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
    let(:psu_doc) do
      {
        schema_provider_s: 'Pennsylvania State University',
        gbl_mdVersion_s: 'Aardvark',
        gbl_indexYear_im: [1701, 1980, 1991, 1995]
      }.to_json
    end
    let(:psu_path) { "#{ogm_path}/edu.psu/metadata-aardvark/Maps/08d-01/geoblacklight.json" }

    # PolicyMap records have placeholder data and should be skipped
    let(:policymap_doc) do
      {
        schema_provider_s: 'Geoblacklight',
        gbl_mdVersion_s: 'Aardvark'
      }.to_json
    end
    let(:policymap_path) { "#{ogm_path}/shared-repository/gbl-policymap/records/geoblacklight.json" }

    let(:psu_doc2_hash) do
      {
        schema_provider_s: 'Pennsylvania State University',
        gbl_mdVersion_s: 'Aardvark',
        gbl_indexYear_im: [1538]
      }
    end
    let(:psu_doc2) { psu_doc2_hash.to_json }
    let(:psu_path2) { "#{ogm_path}/edu.psu/metadata-aardvark/Maps/08d-01/geoblacklight_2.json" }

    before do
      allow(Find).to receive(:find).and_yield(psu_path).and_yield(policymap_path).and_yield(psu_path2)
      allow(File).to receive(:read).with(psu_path).and_return(psu_doc)
      allow(File).to receive(:read).with(policymap_path).and_return(policymap_doc)
      allow(File).to receive(:read).with(psu_path2).and_return(psu_doc2)
    end

    it 'skips PolicyMap records in shared-repository' do
      docs = harvester.docs_to_index.to_a
      expect(docs.length).to eq(2)
      expect(docs.first.last).to eq(psu_path)
      expect(docs.last.last).to eq(psu_path2)
    end

    context 'when access is restricted' do
      let(:psu_doc2) { psu_doc2_hash.merge({ dct_accessRights_s: 'Restricted' }).to_json }

      it 'skips the record' do
        docs = harvester.docs_to_index.to_a
        expect(docs.length).to eq(1)
        expect(docs.first.last).to eq(psu_path)
      end
    end

    it 'transforms provider name based on repository' do
      docs = harvester.docs_to_index.to_a
      expect(docs.first.first['schema_provider_s']).to eq('Penn State')
    end

    it 'generates hierarchical years for the year facet' do
      docs = harvester.docs_to_index.to_a
      expect(docs.first.first['date_hierarchy_sm']).to contain_exactly(
        '1700-1799', '1900-1999',
        '1700-1799:1700-1709', '1900-1999:1980-1989', '1900-1999:1990-1999',
        '1700-1799:1700-1709:1701', '1900-1999:1980-1989:1980', '1900-1999:1990-1999:1991', '1900-1999:1990-1999:1995'
      )
      expect(docs.last.first['date_hierarchy_sm']).to contain_exactly(
        '1500-1599', '1500-1599:1530-1539',
        '1500-1599:1530-1539:1538'
      )
    end

    context 'when record contains themes outside the controlled vocabulary' do
      let(:psu_doc) do
        psu_doc2_hash.merge({ dcat_theme_sm: %w[Agriculture Biota Farming] }).to_json
      end

      it 'filters theme data to fit controlled vocabulary' do
        docs = harvester.docs_to_index.to_a
        expect(docs.first.first['dcat_theme_sm']).to eq(%w[Agriculture])
      end
    end
  end
end
