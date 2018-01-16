[![Build Status](https://travis-ci.org/sul-dlss/earthworks.svg?branch=master)](https://travis-ci.org/sul-dlss/earthworks)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/earthworks/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/earthworks?branch=master)

## EarthWorks

Geospatial discovery application for Stanford University Libraries. Built using:

* [GeoBlacklight](https://github.com/geoblacklight)
* [gis-robot-suite](https://github.com/sul-dlss/gis-robot-suite)
* [OpenGeoMetadatda](https://github.com/opengeometadata)

## Installation

```
# Clone repository
$ git clone git@github.com:sul-dlss/earthworks.git

# Install for development
$ rake earthworks:install
```

### Running tests

#### Running continuous integration tests
```
$ rake ci
```

#### Running data integration tests
**Important!!!**
Must be run with a production index passed in using the `TEST_SOLR_URL` env variable. If ssh tunneling, make *sure* to **NOT** run rake ci while tunneled as it may delete the index.

```
$ TEST_SOLR_URL=http://example.com:8080/solr/core_name rake integration
```
### Running application
```
$ solr_wrapper &
$ rails s
```

### Running OpenGeoMetadata indexing
To ingest the metadata in OpenGeoMetadata into the Solr index (as defined by `config/blacklight.yml`), use:

```
$ mkdir /var/tmp/opengeometadata # optional, but recommended on servers
$ rake earthworks:opengeometadata:pipeline
```
