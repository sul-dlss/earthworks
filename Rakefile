# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

desc 'Execute the test build that runs in CI'
task ci: %i[rubocop environment] do
  require 'solr_wrapper'

  ENV['environment'] = 'test'

  Rake::Task['db:migrate'].invoke
  SolrWrapper.wrap do |solr|
    solr.with_collection(name: 'blacklight-core', dir: "#{Rails.root}/config/solr_configs") do
      Rake::Task['geoblacklight:solr:seed'].invoke
      Rake::Task['earthworks:spec:without-data-integration'].invoke
    end
  end
end

desc 'Execute the integration test build against production index'
task integration: [:environment] do
  ENV['environment'] = 'test'

  Rake::Task['earthworks:spec:data-integration'].invoke
end
