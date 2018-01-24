# Deploys to all production nodes

set :bundle_without, %w[test development deployment].join(' ')

server 'kurma-earthworks1-prod.stanford.edu', user: 'geostaff', roles: %w[web db app whenevs]
server 'kurma-earthworks2-prod.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'kurma-earthworks-worker-prod-a.stanford.edu', user: 'geostaff', roles: %w[app background]


Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_role, :background
set :sidekiq_processes, 5
