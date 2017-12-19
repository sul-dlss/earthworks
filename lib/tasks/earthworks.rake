# sitemap:create to generate sitemaps, 
# sitemap:refresh to generate sitemaps and ping search engines, 
# sitemap:clean to remove sitemap files
require 'sitemap_generator/tasks' 

namespace :earthworks do
  desc 'Install EarthWorks'
  task install: [:environment] do
    Rake::Task['db:migrate'].invoke
  end
  desc 'Index test fixtures'
  task :fixtures do
    Rake::Task['geoblacklight:solr:seed'].invoke
  end
  desc 'Run an EarthWorks server'
  task :server, [:rails_server_args] do |_t, args|
    Rake::Task['db:migrate'].invoke
    SolrWrapper.wrap do |solr|
      solr.with_collection(name: 'blacklight-core', dir: "#{Rails.root}/config/solr_configs") do
        Rake::Task['geoblacklight:solr:seed'].invoke
        system "bundle exec rails s #{args[:rails_server_args]}"
      end
    end
  end
  namespace :spec do
    begin
      require 'rspec/core/rake_task'
      desc 'spec task that runs only data-integration tests (run locally against production data)'
      RSpec::Core::RakeTask.new('data-integration') do |t|
        t.rspec_opts = '--tag data-integration'
      end
      desc 'spec task that ignores data-integration tests (run during local development/travis on local data)'
      RSpec::Core::RakeTask.new('without-data-integration') do |t|
        t.rspec_opts =  '--tag ~data-integration'
      end
      task 'spec:all' => 'test:prepare'
    rescue LoadError => e
      desc 'rspec not installed'
      task 'data-integration' do
        abort 'rspec not installed'
      end
      desc 'rspec not installed'
      task 'without-data-integration' do
        abort 'rspec not installed'
      end
    end
  end
  desc 'Remediate geoblacklight.json schema from preversion to 1.0'
  task :remediate_geoblacklight_schema do
    Dir.glob("#{Rails.root}/spec/fixtures/solr_documents/*.json").each do |fn|
      data = JSON.parse(File.read(fn))
      data['geoblacklight_version'] = '1.0'
      %w(uuid georss_polygon_s georss_point_s georss_box_s dc_relation_sm solr_issued_i).each do |k|
        if data.include?(k)
          puts "Deleting #{k} for #{data['layer_slug_s']}"
          data.delete(k)
        end
      end
      File.open(fn, 'w') {|f| f << JSON.pretty_generate(data) }
    end
  end
  namespace :geomonitor do
    desc 'Update the layers GeoMonitor checks from the Solr index'
    task update: [:environment] do
      response = Blacklight.default_index.connection.get(
        'select',
        params: { q: '*:*', fl: '*', rows: 999_999 }
      )
      docs = response.try(:[], 'response').try(:[], 'docs')
      docs.each do |doc|
        puts "Updating GeoMonitor::Layer #{doc['layer_slug_s']}"
        GeoMonitor::Layer.from_geoblacklight(doc.to_json).save
      end
    end
    desc 'Check all of the active GeoMonitor layers'
    task check: [:environment] do
      GeoMonitor::Layer.where(active: true).find_each do |layer|
        puts "Checking #{layer.slug}"
        layer.check
      end
    end
  end
end
