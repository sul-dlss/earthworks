# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'

every :day, at: '1:04 am', roles: %i[cron] do
  rake 'earthworks:clear_download_cache_stale_files'
end

every :day, at: '3:04 am', roles: %i[cron] do
  rake 'earthworks:prune_old_guest_user_data[3]'
end

every :day, at: '4:04 am', roles: %i[cron] do
  rake 'earthworks:prune_old_search_data[14]'
end

every :day, at: '5:04 am', roles: %i[cron] do
  rake 'geocombine:pull', environment_variable: 'OGM_PATH=/var/cache/earthworks/opengeometadata RAILS_ENV'
  rake 'geocombine:index', environment_variable: 'OGM_PATH=/var/cache/earthworks/opengeometadata RAILS_ENV'
end
