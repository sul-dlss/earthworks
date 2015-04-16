require 'rails_helper'

describe SuggestController do
  describe 'GET index' do
    it 'assigns @response' do
      get :index, format: 'json'
      expect(assigns(:response)).to be_an Earthworks::Suggest::Response
    end
    it 'renders json' do
      get :index, format: 'json'
      expect(response.body).to eq [].to_json
    end
    it 'returns suggestions' do
      get :index, format: 'json', q: 'st'
      json = JSON.parse(response.body)
      expect(json.count).to eq 2
      expect(json.first['term']).to eq 'stanford'
    end
  end
end
