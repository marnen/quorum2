#!/usr/bin/env sh

# PostGIS installation stuff from https://github.com/geoalchemy/geoalchemy2/pull/43/files
# TODO: this could really use some refinement

printf >&2 Installing PostGIS...
sudo apt-add-repository -y ppa:sharpie/for-science
sudo apt-add-repository -y ppa:sharpie/postgis-nightly
sudo apt-get update
sudo apt-get install postgresql-9.1-postgis -q
printf >&2 "done\n"
