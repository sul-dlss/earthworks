# AGENTS.md

Guidance for LLM agents working in the EarthWorks repo. EarthWorks is a
Stanford geospatial discovery app built on Blacklight 9 + GeoBlacklight 6
(alpha), Rails 8.1.

## Commands

### Tests
- The test suite **requires Solr** and **self-manages it via Docker**. The
  canonical command is `bin/rake ci`, which runs `db:migrate` →
  `earthworks:fixtures` (indexes test docs) → `rspec`, all wrapped in
  `docker compose up -d index` / `docker compose stop index`. Docker must be
  running; do **not** start `solr_wrapper` separately when using `bin/rake ci`
  (they will collide on port 8983).
- `bin/rspec ...` alone only works if Solr is already up and fixtures are
  indexed. For non-Solr unit specs (services, models) this is usually fine.
- Full CI pre-flight (what GitHub Actions runs): `bundle exec bin/ci`. It
  executes `bin/setup --skip-server` → `bin/rubocop` → `bin/importmap audit` →
  `bin/rake ci`.
- Run a single spec: `bin/rspec spec/path/to_spec.rb:LINE`.
- `:js` feature specs use `selenium_chrome_headless`; Chrome/Chromium must be
  installed (see `spec/features/axe_spec.rb`, `feedback_form_spec.rb`).
- WebMock disables all outbound network except localhost (`rails_helper.rb`).
  `FactoryBot.lint` runs before the suite, so factories must be valid.

### Safety
- **Never run `bin/rake ci` over an SSH tunnel to production.** It seeds
  fixtures into whatever `TEST_SOLR_URL`/`SOLR_URL` points at and can wipe the
  production index. (README warning.)

### Lint / format
- Use the binstub: `bin/rubocop` (it preloads `.rubocop.yml`). Strict config
  with many cops enabled; `inherit_from: .rubocop_todo.yml` carries exclusions
  — regenerate with `rubocop --auto-gen-config` if needed, do not hand-edit
  the todo file.
- `bin/importmap audit` checks JS pins for vulnerabilities (part of `bin/ci`).

### Dev server
- `bin/dev` (runs `Procfile.dev` via foreman) — only starts the Rails server.
  CSS is **not** auto-watched; rebuild SCSS manually with `bin/build-css` (or
  `npm run build:css`). The README's "live reloading" claim is stale.
- Solr for dev: either `solr_wrapper` or `docker compose up index` (Solr 9.10,
  core `blacklight-core`, config from `config/solr_configs`).
- Seed test data: `bin/rake earthworks:fixtures`.

## Architecture notes

- Default DB is **SQLite** in dev/test (`db/*.sqlite3`); Postgres is production
  only. `.env` / `.env.test` contain commented-out `DATABASE_URL` / `REDIS_URL`
  lines to switch to the docker-compose `db` (postgres 12) / `cache` (redis 6.2)
  services. `dotenv` loads these files.
- Frontend: **Importmap** (no Node bundler for JS) — pins in
  `config/importmap.rb` (local + CDN). Assets via Propshaft; SCSS via dart-sass.
  `package.json` deps (leaflet, openlayers, bootstrap, blacklight-frontend)
  are CSS/load-path sources, not bundled.
- App entrypoint is `app/controllers/catalog_controller.rb` (Blacklight config,
  facets, search fields). GeoBlacklight engine is mounted at `/geoblacklight`.
- UI uses ViewComponents in `app/components` (including `blacklight/` overrides);
  test these as `type: :component`.
- Live indexing is driven by a Kafka consumer:
  `app/consumers/sdr_consumer.rb` (Racecar), which pulls SDR item updates and
  writes to Solr via `CocinaService` / `SolrService` in `app/services`. In
  production this runs under systemd (Capistrano `indexer` role).
- Sidekiq for background jobs; web UI mounted at `/queues` (Apache-gated to
  admins in prod).
- Custom rake tasks live in `lib/tasks/earthworks.rake` (fixture indexing,
  guest-user/search pruning, download-cache cleanup). Cron schedule is
  `config/schedule.rb` (`whenever`, role `:cron`).
- GeoCombine (`geocombine:*` tasks) pulls/indexes OpenGeoMetadata records.

## Deploy

- Capistrano via `Jenkinsfile`: push to `main` deploys **stage** then **uat**;
  pushing a `v*` tag deploys **prod**. Do not run cap locally expecting prod —
  the `DEPLOY=1` env gates branch prompts.
- Shared config files (`database.yml`, `honeybadger.yml`, `blacklight.yml`,
  `newrelic.yml`, `robots.txt`) and dirs (`config/settings`, `log`, `tmp/*`,
  `vendor/bundle`) are symlinked from a shared dir on the servers via
  `capistrano-shared_configs`; they are **not** in the repo for prod.

## Conventions

- Commit messages are conventional short summaries; PR-merge workflow is used
  (see `git log`). Branches are short-lived and topic-named.
- Ruby: `TargetRubyVersion: 3.3` in `.rubocop.yml`, but CI runs Ruby 4.0 and the
  Jenkins deploy uses 3.4.1. Match the toolchain that's already installed.
- `RSpec/MultipleExpectations` is **disabled**; `RSpec/DescribeClass` excludes
  `spec/features/**` and `spec/integration/**`. Don't fight these.
