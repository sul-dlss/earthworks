# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

BLACKLIGHT_JETTY_VERSION = '4.10.2'
ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v#{BLACKLIGHT_JETTY_VERSION}.zip"
require 'jettywrapper'

desc 'Execute the test build that runs on travis'
task :ci => [:environment] do
  if Rails.env.test?
    Rake::Task['db:migrate'].invoke
    Rake::Task['earthworks:download_and_unzip_jetty'].invoke
    Rake::Task['earthworks:copy_solr_configs'].invoke
    jetty_params = Jettywrapper.load_config
    Jettywrapper.wrap(jetty_params) do
      Rake::Task['geoblacklight:solr:seed'].invoke
      Rake::Task['earthworks:spec:without-data-integration'].invoke
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
