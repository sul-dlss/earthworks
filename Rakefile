# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rubocop/rake_task'
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Execute the test build that runs on travis'
task :ci => [:environment] do
  require 'solr_wrapper'
  if Rails.env.test?
    Rake::Task['rubocop'].invoke
    Rake::Task['db:migrate'].invoke
    SolrWrapper.wrap do |solr|
      solr.with_collection(name: 'blacklight-core', dir: "#{Rails.root}/config/solr_configs") do
        Rake::Task['geoblacklight:solr:seed'].invoke
        Rake::Task['earthworks:spec:without-data-integration'].invoke
      end
    end
  else
    system('rake ci RAILS_ENV=test')
  end
end
desc 'Execute the integration test build against production index'
task :integration => [:environment] do
  if Rails.env.test?
    Rake::Task['earthworks:spec:data-integration'].invoke
  else
    system('rake integration RAILS_ENV=test')
  end
end
