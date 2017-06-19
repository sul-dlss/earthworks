set :bundle_without, %w[sqlite production test development].join(' ')

server 'kurma-earthworks-stage.stanford.edu', user: 'geostaff', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'stage'
