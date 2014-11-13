set :deploy_host, ask("Server", 'e.g. hostname with no ".stanford.edu", no server node designator, and no environment')
set :bundle_without, %w{sqlite test}.join(' ')

server_extensions = [1, 2]

server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}#{extension}-prod.stanford.edu", user: fetch(:user), roles: %w{web db app}
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"