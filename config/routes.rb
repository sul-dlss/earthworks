require 'sidekiq/web'

Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  mount OkComputer::Engine, at: '/status'
  # API compatibility with is_it_working checks
  match '/is_it_working' => 'ok_computer/ok_computer#index', via: %i[get options]

  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  get '/catalog/:id/code_snippet' => 'catalog#code_snippet'
  get 'restricted_proxy/geoserver/:webservice' => 'restricted_proxy#access'

  devise_for :users, skip: %i[registrations passwords sessions]
  devise_scope :user do
    get 'restricted/users/auth/webauth' => 'login#login', as: :new_user_session
    match 'users/auth/webauth/logout' => 'devise/sessions#destroy', :as => :destroy_user_session,
          :via => Devise.mappings[:user].sign_out_via
  end

  resource :feedback_form, path: 'feedback', only: %i[new create]
  get 'feedback' => 'feedback_forms#new'

  concern :gbl_exportable, Geoblacklight::Routes::Exportable.new
  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :gbl_exportable
  end

  concern :gbl_wms, Geoblacklight::Routes::Wms.new
  namespace :wms do
    concerns :gbl_wms
  end

  concern :gbl_downloadable, Geoblacklight::Routes::Downloadable.new
  namespace :download do
    concerns :gbl_downloadable
  end

  resources :download, only: [:show]

  mount Geoblacklight::Engine => 'geoblacklight'
  mount BlacklightDynamicSitemap::Engine => '/'
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # @note Only admins should be able to access the Sidekiq web UI. This is
  # accomplished using Apache configuration that is managed by Puppet which
  # require a user be logged in as a developer to access /queues
  mount Sidekiq::Web => '/queues'
end
