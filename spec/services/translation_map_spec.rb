# frozen_string_literal: nil

require 'rails_helper'

RSpec.describe TranslationMap do
  subject(:translation_map) { described_class.new(name) }

  let(:name) { 'test_map' }
  let(:mock_yaml_data) do
    {
      'exact_key' => 'exact_value',
      '/^regex_.*$/' => 'regex_value',
      'other_key' => 'other_value',
      '/foo/' => 'bar'
    }
  end

  before do
    allow(YAML).to receive(:load_file).and_call_original
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join('config/translation_maps/test_map.yml'))
      .and_return(mock_yaml_data)
  end

  describe '#translate' do
    context 'with exact match keys' do
      it 'translates exact match values' do
        expect(translation_map.translate('exact_key')).to eq(['exact_value'])
      end

      it 'returns an empty array if no matches are found' do
        expect(translation_map.translate('unmapped_key')).to eq([])
      end
    end

    context 'with regex match keys' do
      it 'translates values matching the regex key' do
        expect(translation_map.translate('regex_something')).to eq(['regex_value'])
      end

      it 'ignores regex matches if they do not match' do
        expect(translation_map.translate('something_regex')).to eq([])
      end

      it 'handles mid-string regex keys properly' do
        expect(translation_map.translate('my foo bar')).to eq(['bar'])
      end
    end

    context 'with array inputs' do
      it 'translates multiple values' do
        input = %w[exact_key regex_hello unmapped]
        expect(translation_map.translate(input)).to contain_exactly('exact_value', 'regex_value')
      end

      it 'de-duplicates translated results' do
        input = %w[exact_key exact_key regex_1 regex_2]
        expect(translation_map.translate(input)).to contain_exactly('exact_value', 'regex_value')
      end
    end

    context 'with nil or empty inputs' do
      it 'returns an empty array for nil' do
        expect(translation_map.translate(nil)).to eq([])
      end

      it 'returns an empty array for empty array' do
        expect(translation_map.translate([])).to eq([])
      end
    end

    context 'when converting non-string values' do
      let(:mock_yaml_data) do
        {
          '123' => 'number_value'
        }
      end

      it 'coerces non-string values to strings before translation' do
        expect(translation_map.translate(123)).to eq(['number_value'])
      end
    end
  end

  describe 'integration with actual files' do
    let(:name) { 'geo_theme' }

    it 'loads actual translation maps from the config directory' do
      # Since we only stubbed 'test_map.yml', 'geo_theme' will load the real file
      map = described_class.new('geo_theme')
      expect(map.translate('Agriculture')).to eq(['Agriculture'])
      expect(map.translate('Farming')).to eq(['Agriculture'])
    end
  end
end
