set :bundle_without, %w[test development deployment].join(' ')

server 'kurma-earthworks-stage.stanford.edu', user: 'geostaff', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
