set :bundle_without, %w[sqlite production test].join(' ')

server 'kurma-earthworks-dev.stanford.edu', user: 'geostaff', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'development'
