#!/usr/bin/env sh
printf >&2 'Setting up config files... '
cat >config/database.yml <<EOF
test:
  adapter: postgis
  database: quorum2_test
  username: postgres
  encoding: UTF8
EOF
printf >&2 'database.yml '

cp config/config-orig.yml config/config.yml
printf >&2 'config.yml '

printf >&2 "done\n"