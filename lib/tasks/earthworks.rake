require 'earthworks/harvester'

namespace :earthworks do
  desc 'Install EarthWorks'
  task install: [:environment] do
    Rake::Task['db:migrate'].invoke
  end
  desc 'Index test fixtures'
  task :fixtures do
    Rake::Task['geoblacklight:index:seed'].invoke
  end
  desc 'Run an EarthWorks server'
  task :server, [:rails_server_args] do |_t, args|
    Rake::Task['db:migrate'].invoke
    SolrWrapper.wrap do |solr|
      solr.with_collection(name: 'blacklight-core', dir: "#{Rails.root}/config/solr_configs") do
        Rake::Task['geoblacklight:index:seed'].invoke
        system "bundle exec rails s #{args[:rails_server_args]}"
      end
    end
  end
  namespace :spec do
    require 'rspec/core/rake_task'
    desc 'spec task that runs only data-integration tests (run locally against production data)'
    RSpec::Core::RakeTask.new('data-integration') do |t|
      t.rspec_opts = '--tag data-integration'
    end
    desc 'spec task that ignores data-integration tests (run during local development/travis on local data)'
    RSpec::Core::RakeTask.new('without-data-integration') do |t|
      t.rspec_opts = '--tag ~data-integration'
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
  desc 'Remediate geoblacklight.json schema from preversion to 1.0'
  task :remediate_geoblacklight_schema do
    fields = %w[uuid georss_polygon_s georss_point_s georss_box_s dc_relation_sm solr_issued_i]
    Dir.glob("#{Rails.root}/spec/fixtures/solr_documents/*.json").each do |fn|
      data = JSON.parse(File.read(fn))
      data['geoblacklight_version'] = '1.0'
      fields.each do |field|
        if data.include?(field)
          puts "Deleting #{field} for #{data['layer_slug_s']}"
          data.delete(field)
        end
      end
      File.open(fn, 'w') { |f| f << JSON.pretty_generate(data) }
    end
  end
  namespace :geomonitor do
    desc 'Update the layers GeoMonitor checks from the Solr index'
    task update: [:environment] do
      num_found = 999_999 # Set sufficiently large, and then update in first query
      rows = 100
      start = 1
      while start < num_found
        puts "Selecting from Solr at #{start}, #{rows} rows"
        response = Blacklight.default_index.connection.get(
          'select',
          params: { q: '*:*', fl: '*', start:, rows: }
        )
        num_found = response['response']['numFound'].to_i
        docs = response.try(:[], 'response').try(:[], 'docs')
        docs.each do |doc|
          puts "Updating GeoMonitor::Layer #{doc['layer_slug_s']}"
          GeoMonitor::Layer.from_geoblacklight(doc.to_json).save!
        end
        start += rows
      end
    end
    desc 'Check all of the active GeoMonitor layers'
    task check: [:environment] do
      GeoMonitor::Layer.where(active: true).find_each(batch_size: 250) do |layer|
        puts "Enqueueing check for #{layer.slug}"
        CheckLayerJob.set(wait: ((1.minute)...(4.hours)).to_a.sample.seconds).perform_later(layer)
      end
    end
    desc 'Check all of the active Stanford layers'
    task check_stanford: [:environment] do
      GeoMonitor::Layer.where(active: true, institution: 'Stanford').find_each(batch_size: 250) do |layer|
        puts "Enqueueing check for #{layer.slug}"
        CheckLayerJob.set(wait: ((1.minute)...(4.hours)).to_a.sample.seconds).perform_later(layer)
      end
    end
    desc 'Check all of the active public layers'
    task check_public: [:environment] do
      GeoMonitor::Layer.where(active: true, rights: 'Public').find_each(batch_size: 250) do |layer|
        puts "Enqueueing check for #{layer.slug}"
        CheckLayerJob.set(wait: ((1.minute)...(4.hours)).to_a.sample.seconds).perform_later(layer)
      end
    end
    desc 'Reset availability for GeoMonitor layers'
    task reset_availability: [:environment] do
      GeoMonitor::Layer.find_each do |layer|
        data = [{
          layer_availability_score_f: { set: nil },
          layer_slug_s: layer.slug
        }]
        Indexer.new.solr_update(data)
      end
    end
  end

  # Customized tasks for OpenGeoMetadata records
  namespace :opengeometadata do
    desc 'Initialize OpenGeoMetadata repositories'
    task :clone do
      harvester = Earthworks::Harvester.new(ogm_repos: Settings.OGM_REPOS)
      harvester.clone_all
    end

    desc 'Fetch updated OpenGeoMetadata records for indexing'
    task :pull do
      harvester = Earthworks::Harvester.new(ogm_repos: Settings.OGM_REPOS)
      harvester.pull_all
    end

    desc 'Index OpenGeoMetadata repositories'
    task :index do
      harvester = Earthworks::Harvester.new(ogm_repos: Settings.OGM_REPOS)
      indexer = GeoCombine::Indexer.new
      indexer.index(harvester.docs_to_index)
    end
  end

  desc 'Prune old guest users from the database'
  task :prune_old_guest_user_data, [:months_old] => [:environment] do |_t, args|
    # rubocop:disable Layout/MultilineMethodCallIndentation
    old_bookmarkless_guest_users_ids = User.guests_without_bookmarks
      .where('users.updated_at < :date', { date: args[:months_old].to_i.months.ago })
      .pluck(:id)
    # rubocop:enable Layout/MultilineMethodCallIndentation

    User.delete(old_bookmarkless_guest_users_ids)
  end

  desc 'Clear Rack::Attack cache'
  task clear_rack_attack_cache: [:environment] do
    if Settings.THROTTLE_TRAFFIC
      # This functionality will be available as Rack::Attack.reset! but as of 6.2.2 this is not released
      store = Rack::Attack.cache.store
      if store.respond_to?(:delete_matched)
        store.delete_matched("#{Rack::Attack.cache.prefix}*")
      else
        puts "Error Clearing Rack::Attack cache. Store #{store.class.name} does not respond to #delete_matched"
      end
    end
  end

  desc 'Clean earthworks stale download files'
  task clear_download_cache_stale_files: [:environment] do
    # Commented line below is for testing purposes, it will just list the files that
    # would be deleted with timestamp created
    # `find /var/cache/earthworks/downloads -type f -atime +14 -printf '%TY-%Tm-%Td %TH:%TM %p\n'`
    `find #{Settings.DOWNLOAD_PATH} -type f -atime +#{Settings.download_cache_expiry_time_days} -delete`
  end

  desc 'Prune old search data from the database'
  task :prune_old_search_data, [:days_old] => [:environment] do |_t, args|
    chunk = 20_000
    raise ArgumentError, 'days_old is expected to be greater than 0' if args[:days_old].to_i <= 0

    total = Search.where('updated_at < :date', { date: (Date.today - args[:days_old].to_i) }).count
    total -= (total % chunk) if (total % chunk) != 0
    i = 0
    while i < total
      # might want to add a .where("user_id = NULL") when we have authentication hooked up.
      Search.destroy(Search.order('updated_at').limit(chunk).pluck(:id))
      i += chunk
      sleep(10)
    end
  end
end
