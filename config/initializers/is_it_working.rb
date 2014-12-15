Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  # Check the ActiveRecord database connection without spawning a new thread
  h.check :active_record, async: false

  # Check that the NFS mount directory is available with read/write permissions
  h.check :directory, path: Rails.root + "tmp/cache/downloads", permission: [:read, :write]
end
