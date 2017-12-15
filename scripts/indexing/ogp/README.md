This code downloads OpenGeoPortal (OGP) metadata records into `data/` and
then validates each record based on a bunch of heuristics to keep only
"quality" metadata and then writes that to `valid.json`.

For example:

```
mkdir data
bundle exec ruby download.rb
bundle exec ruby validate.rb > validate.log
ls -l ogp.json
```

Then to convert to GeoBlacklight and index:

```
bundle exec ruby to_geoblacklight.rb
ls -l geoblacklight.json
OGP_PATH=`pwd` bundle exec rake geocombine:index
```
