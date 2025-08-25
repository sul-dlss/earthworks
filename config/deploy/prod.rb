set :bundle_without, %w[test development deployment].join(' ')

server 'earthworks-prod-a.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-prod-b.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-worker-prod-a.stanford.edu', user: 'geostaff', roles: %w[app background cron indexer]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
