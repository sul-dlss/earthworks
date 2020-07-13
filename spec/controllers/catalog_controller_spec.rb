# frozen_string_literal: true

require 'rails_helper'

describe CatalogController do
  describe 'Mapping legacy IDs to new ones' do
    it 'should redirect  from an old ID to a new one (when it does not exist)' do
      get :show, params: { id: 'mit-ao-p2roads-2005' }

      expect(response).to redirect_to(solr_document_path('mit-f4b5a2yjdflbi'))
    end
  end
end
