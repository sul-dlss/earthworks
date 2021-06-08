require 'rails_helper'

RSpec.describe RightsMetadata do
  subject(:instance) { described_class.new(rights_metadata) }

  describe '#license?' do
    subject { instance.license? }

    context 'with a license' do
      let(:rights_metadata) do
        <<~EOF
          <rightsMetadata>
            <use>
              <license>https://opensource.org/licenses/BSD-3-Clause</license>
            </use>
          </rightsMetadata>
        EOF
      end

      it { is_expected.to be true }
    end

    context 'without a license' do
      let(:rights_metadata) do
        <<~EOF
          <rightsMetadata>
          <use></use>
          </rightsMetadata>
        EOF
      end

      it { is_expected.to be false }
    end
  end

  describe '#license' do
    let(:license) { subject.license }

    context 'with a license node' do
      let(:rights_metadata) do
        <<~EOF
          <rightsMetadata>
            <use>
              <license>https://opensource.org/licenses/BSD-3-Clause</license>
            </use>
          </rightsMetadata>
        EOF
      end

      it 'decodes the value' do
        expect(license.description).to eq 'This work is licensed under a BSD-3-Clause "New" or "Revised" License'
      end
    end

    context 'with a uri attribute' do
      let(:rights_metadata) do
        <<~EOF
          <rightsMetadata>

            <use>
              <machine type="creativeCommons" uri="https://creativecommons.org/licenses/by-nc/4.0/legalcode">junk</machine>
            </use>
          </rightsMetadata>
        EOF
      end

      it 'decodes the value' do
        expect(license.description).to eq 'This work is licensed under a CC-BY-NC-4.0 Attribution-NonCommercial International'
      end
    end

    context 'with a code' do
      let(:rights_metadata) do
        <<~EOF
          <rightsMetadata>
            <use>
              <machine type="creativeCommons">by-nc</machine>
            </use>
          </rightsMetadata>
        EOF
      end

      it 'decodes the value' do
        expect(license.description).to eq 'This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License'
      end
    end
  end
end
