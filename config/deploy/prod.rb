# Deploys to all production nodes

set :deploy_host, 'kurma-earthworks'
set :bundle_without, %w{sqlite test development}.join(' ')

server_extensions = [1, 2]

server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}#{extension}-prod.stanford.edu", user: fetch(:user), roles: %w{web db app}
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"
