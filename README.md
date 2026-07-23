# EarthWorks

[![CI status](https://github.com/sul-dlss/earthworks/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/earthworks/actions/workflows/ruby.yml)

Geospatial discovery application for Stanford University Libraries, built using [GeoBlacklight](https://github.com/geoblacklight).

## Developing

For the currently supported Ruby version, see the `.github/workflows/ruby.yml` file.

### Setup

Pull down the code:

```sh
git clone git@github.com:sul-dlss/earthworks.git
```

Install dependencies and prepare the database:

```sh
bin/setup
```

For a basic development server, you can use GeoBlacklight's rake task, which will run solr via Docker and Rails:

```sh
bin/rake geoblacklight:server
```

### Supporting services

Earthworks uses a solr index for search, and optionally a Redis cache and a Postgresql database to mimic the production setup.

To run the production setup, you need to uncomment the `DATABASE_URL`, `REDIS_URL`, `REDIS_HOST`, and `REDIS_PORT` lines in the `.env[.test]` file(s) (in the project root).

Then you need to invoke the compose file yourself, set up the Postgres database, and run the rails server separately:

```sh
docker compose up -d
bin/setup
bin/dev
```

The Solr connection info is the same as for the basic dev server.

### Indexing data

Earthworks indexes data from multiple sources. The indexing processes run on a dedicated worker machine rather than the main web servers (e.g. `earthworks-worker-prod-a` instead of `earthworks-prod-a`).

#### Stanford data

Stanford data published from SDR is consumed from a Kafka queue via the `SdrConsumer`, which fetches Cocina JSON from PURL and hands it off to the `CocinaToSolrMapper` to transform into OGM Aardvark records. These are then indexed into Solr by the `SolrService`, and the result is reported back to Argo via the `SdrEvents` class. This process is "push", in that the Solr index is updated as soon as new data is published to SDR.

#### External data

External data is fetched from [OpenGeoMetadata](https://github.com/OpenGeoMetadata) via [GeoCombine](https://github.com/OpenGeoMetadata/GeoCombine), which downloads records from the OpenGeoMetadata GitHub organization and places them on a local filesystem. After downloading, the files are indexed into Solr. This process is "pull", in that it is run on a schedule to fetch and index new data. The `config/schedule.rb` controls the `cron` that runs these tasks and [checks in with Honeybadger](https://app.honeybadger.io/projects/49895/check_ins) when they are completed.

To index data yourself in local development, you can use the same tasks:

```sh
bin/rake geocombine:clone
bin/rake geocombine:index
```

For more info on fetching external records, see the [GeoCombine README](https://github.com/OpenGeoMetadata/GeoCombine/blob/main/README.md).

## Testing

You can run the full suite of tests with the `ci` command. **Do not** run this while ssh tunneled as it may delete the production index!

```sh
bin/rake ci
```
