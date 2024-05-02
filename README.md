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
Unless using [Docker](https://www.docker.com/) (see below), proceed to install dependencies and prepare the database:
```sh
bin/setup
```
Start an [Apache Solr](https://solr.apache.org/) instance using [solr_wrapper](https://github.com/cbeer/solr_wrapper):
```sh
solr_wrapper
```
Finally, start the development web server:
```sh
bin/rails server
```
### Using Docker
A more production-like setup using [Redis](https://redis.com/) and [Postgresql](https://www.postgresql.org/) is available via Docker. To create the stack:
```sh
docker compose up
```
Then, to prepare the database:
```sh
docker compose exec app bin/setup
```
Most other commands can be run by prepending `docker compose exec app` to the command, which will execute the command in the `app` container.
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
```sh
bin/rake ci
```
There is also a separate suite of "data integration" tests, which are intended to be run against a production search index.
```sh
export TEST_SOLR_URL=http://example.com:8080/solr/core_name
bin/rake integration
```
