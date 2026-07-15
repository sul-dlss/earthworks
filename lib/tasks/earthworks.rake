namespace :earthworks do
  desc 'Index test fixtures'
  task :fixtures do
    # Index all of Geoblacklight's built-in fixtures
    Rake::Task['geoblacklight:index:seed'].invoke

    # Index our own local fixtures
    fixtures_path = Rails.root.join('spec', 'fixtures', 'solr_documents', '*.json')
    docs = Dir[fixtures_path].map { |file| JSON.parse(File.read(file)) }
    Blacklight.default_index.connection.add docs
    Blacklight.default_index.connection.commit
  end

  desc 'Index from geocombine'
  task index: [:environment, 'geocombine:index'] do
    Honeybadger.check_in(Settings.honeybadger.check_in_id)
  end

  desc 'Prune old guest users from the database'
  task :prune_old_guest_user_data, [:months_old] => [:environment] do |_t, args|
    User.guests_without_bookmarks
        .where('users.updated_at < :date', { date: args[:months_old].to_i.months.ago })
        .in_batches(of: 1000)
        .delete_all
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
      Search.destroy(Search.order(:updated_at).limit(chunk).pluck(:id))
      i += chunk
      sleep(10)
    end
  end
end
