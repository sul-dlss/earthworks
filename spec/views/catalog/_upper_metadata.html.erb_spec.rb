require 'rails_helper'

describe 'catalog/_upper_metadata.html.erb' do
  before { assign(:document, document) }
  describe 'Restricted Stanford document' do
    let(:document) { SolrDocument.new(dc_rights_s: 'Restricted', dct_provenance_s: 'Stanford') }
    it 'displays use and reproduction statement' do
      render
      expect(rendered).to have_css 'dd', text: 'These data are licensed by Stanford Libraries and are available to Stanford University affiliates only. Affiliates are limited to current faculty, staff and students. These data may not be reproduced or used for any purpose without permission. For more information please contact brannerlibrary@stanford.edu.'
    end
  end
  describe 'Public Stanford document' do
    let(:document) { SolrDocument.new(dc_rights_s: 'Public', dct_provenance_s: 'Stanford') }
    it 'displays public use and reproduction statement' do
      render
      expect(rendered).to have_css 'dd', text: 'This item is in the public domain. There are no restrictions on use.'
    end
  end
end
