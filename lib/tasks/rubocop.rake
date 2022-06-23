# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end
rescue LoadError
  # this rescue block is here for deployment to production, where
  # certain dependencies are not expected, and that is OK
  warn 'WARNING: Rubocop was not found and could not be required.'
end
