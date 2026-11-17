# global_alerts clears its cache entry on every boot (in a `to_prepare` hook), which
# would hit Solid Cache's database table before `db:migrate` has had a chance to
# create it (e.g. during the first deploy's assets:precompile or db:migrate). The
# alerts YAML is tiny, so keep it in a per-process memory store instead.
GlobalAlerts::Engine.config.cache = ActiveSupport::Cache::MemoryStore.new
