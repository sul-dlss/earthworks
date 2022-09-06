set :bundle_without, %w[test development deployment].join(' ')

server 'earthworks-stage-a.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-stage-b.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'earthworks-worker-stage-a.stanford.edu', user: 'geostaff', roles: %w[app background]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
