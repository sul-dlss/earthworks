# EarthWorks
[![CI](https://github.com/sul-dlss/earthworks/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/earthworks/actions/workflows/ruby.yml)

Geospatial discovery application for Stanford University Libraries, built using [GeoBlacklight](https://github.com/geoblacklight).

<img src="preview.png" align="center" alt="bay area video arcades slideshow preview">

## Developing

### Pre-requisites
* Ruby 3.1 or 3.2. **Other versions may work but are unsupported.**

### Installing
Pull down the code:
```sh
git clone git@github.com:sul-dlss/earthworks.git
```

#### Run the supporting services
You can do this by either running them directly on your dev machine, or by running them in containers using Docker (you should choose one or the other)

##### Running supporting services directly

Start an [Apache Solr](https://solr.apache.org/) instance using [solr_wrapper](https://github.com/cbeer/solr_wrapper):
```sh
solr_wrapper
```

##### Running supporting services using Docker
A more production-like setup using [Redis](https://redis.com/) and [Postgresql](https://www.postgresql.org/) is available via Docker. To start the stack:
```sh
docker compose up
```

#### Install the Ruby and Javascript dependencies, and prepare the database
Run the setup script:

##### If running the supporting services directly
If you're running the supporting services directly on your dev machine, you can use the default database config and just invoke the script:
```sh
bin/setup
```

##### If running the supporting services in Docker
If you're using containers to run Postgres and Solr, you'll want to point the setup script to the PG container:
```sh
DATABASE_URL='postgresql://earthworks:earthworks@localhost/earthworks?pool=5' bin/setup
```

### Run the application
Finally, start the development web server:

#### If running the supporting services directly
If you're running the supporting services directly on your dev machine, you can use the default database config, and just start Rails server:
```sh
bin/rails server
```

#### If running the supporting services in Docker
If you're using containers to run Postgres and Solr, you'll want to point your app to the PG container:
```sh
DATABASE_URL='postgresql://earthworks:earthworks@localhost/earthworks?pool=5' bin/rails server
```

### Adding data
To add a small amount of test records to the Solr index, you can use the `seed` task:
```sh
bin/rake geoblacklight:solr:seed
```
You can also fetch records from [OpenGeoMetadata](https://github.com/OpenGeoMetadata) using [GeoCombine](https://github.com/OpenGeoMetadata/GeoCombine):
```sh
export OGM_PATH=tmp/opengeometadata     # location to store data
bin/rake geocombine:clone[edu.nyu]      # pull data from NYU
bin/rake geocombine:index               # index data in Solr
```
At Stanford, geospatial data is transformed and indexed by the [gis-robot-suite](https://github.com/sul-dlss/gis-robot-suite).

## Testing
You can run the full suite of tests with the `ci` command. **Do not** run this while ssh tunneled as it may delete the production index!

### If running the supporting services directly
You can just use the default DB config, and run the `ci` task:
```sh
bin/rake ci
```

### If running the supporting services in Docker
If you're using containers to run Postgres and Solr, you'll want to point your test suite to the PG container:
```sh
DATABASE_URL='postgresql://earthworks:earthworks@localhost/earthworks?pool=5' bin/rake ci
```

There is also a separate suite of "data integration" tests, which are intended to be run against a production search index.
```sh
export TEST_SOLR_URL=http://example.com:8080/solr/core_name
bin/rake integration
```
