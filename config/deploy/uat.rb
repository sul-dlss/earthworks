# Deploys to all UAT nodes

set :bundle_without, %w[test development deployment].join(' ')

server 'earthworks-uat-a.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-uat-b.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-worker-uat-a.stanford.edu', user: 'geostaff', roles: %w[app background whenevs]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
