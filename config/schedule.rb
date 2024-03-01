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

every 1.day, at: '9:34pm', roles: %i[whenevs] do
  rake 'earthworks:geomonitor:update'
end

every 1.day, at: ['1:13 am', '7:42 am', '1:13 pm', '7:42 pm'], roles: %i[whenevs] do
  rake 'earthworks:geomonitor:check_stanford'
end

every 2.days, at: ['2:21 am'], roles: %i[whenevs] do
  rake 'earthworks:geomonitor:check_public'
end

every '0 3 * * *', roles: %i[app] do # daily at 3 am
  rake 'earthworks:clear_rack_attack_cache'
end

every 1.day, at: '3:04 am', roles: %i[whenevs] do
  rake 'rake earthworks:prune_old_guest_user_data[3]'
end

every 1.day, at: '4:04 am', roles: %i[whenevs] do
  rake 'rake earthworks:prune_old_search_data[14]'
end

every :tuesday, at: '5:04 am', roles: %i[whenevs] do
  rake 'rake earthworks:opengeometadata:pull'
  rake 'rake earthworks:opengeometadata:index'
end
