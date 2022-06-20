set :application, 'earthworks'
set :repo_url, 'https://github.com/sul-dlss/earthworks.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call unless ENV['DEPLOY']

set :deploy_to, '/opt/app/geostaff/earthworks'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files,
    %w[config/database.yml config/honeybadger.yml config/secrets.yml config/blacklight.yml public/robots.txt
       config/newrelic.yml]

# Default value for linked_dirs is []
set :linked_dirs, %w[config/settings log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :honeybadger_env, fetch(:stage)

set :whenever_roles, [:whenevs]

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'tmp:cache:clear'
      # end
    end
  end
  after :restart, :restart_sidekiq do
    on roles(:background) do
      sudo :systemctl, 'restart', 'sidekiq-*', raise_on_non_zero_exit: false
    end
  end
end
