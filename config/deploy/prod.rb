# Deploys to all production nodes

set :bundle_without, %w[sqlite test development].join(' ')

server 'kurma-earthworks1-prod.stanford.edu', user: 'geostaff', roles: %w[web db app]
server 'kurma-earthworks2-prod.stanford.edu', user: 'geostaff', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
