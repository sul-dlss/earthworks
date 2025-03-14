require 'rails_helper'

describe RestrictedProxyController do
  include Devise::Test::ControllerHelpers

  context 'when the current user is anonymous' do
    it 'returns an unauthorized status' do
      get :access, params: { webservice: 'wms', format: 'image/png' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'with a current user' do
    before do
      allow(HTTP).to receive(:get).and_return(
        instance_double(HTTP::Response, {
                          headers: { 'Content-Type' => 'image/png', 'geowebcache-stuff' => 'foo' },
                          status: 200,
                          body: 'image!'
                        })
      )
    end

    let(:stacks_token) { JWT.encode({}, Settings.geo_proxy_secret) }

    it 'fetches from the proxy' do
      get :access, params: { webservice: 'wms', format: 'image/png', stacks_token: }
      expect(response).to have_http_status(:ok)
    end

    it 'returns the body' do
      get :access, params: { webservice: 'wms', format: 'image/png', stacks_token: }
      expect(response.body).to eq 'image!'
    end

    it 'passes through headers' do
      get :access, params: { webservice: 'wms', format: 'image/png', stacks_token: }
      expect(response.headers.to_h).to include 'content-type' => 'image/png',
                                               'geowebcache-stuff' => 'foo'
    end
  end
end
