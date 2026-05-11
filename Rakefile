# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'open3'
require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

def system_with_error_handling(*args)
  Open3.popen3(*args) do |_stdin, stdout, stderr, thread|
    puts stdout.read
    raise "Unable to run #{args.inspect}: #{stderr.read}" unless thread.value.success?
  end
end

def with_solr(&)
  puts 'Starting Solr'
  system_with_error_handling 'docker compose up -d index'
  sleep 5 # give solr a few seconds to load the core config and be ready
  yield
ensure
  puts 'Stopping Solr'
  system_with_error_handling 'docker compose stop index'
end

desc 'Execute the test build that runs in CI'
task ci: %i[rubocop environment] do
  ENV['environment'] = 'test'

  Rake::Task['db:migrate'].invoke
  with_solr do
    Rake::Task['earthworks:fixtures'].invoke
    Rake::Task['spec'].invoke
  end
end
