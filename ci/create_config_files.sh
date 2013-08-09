#!/usr/bin/env sh
printf >&2 'Setting up config files... '
cat >config/database.yml <<EOF
test:
  adapter: postgis
  database: quorum2_test
  username: postgres
  encoding: UTF8
EOF
printf >&2 'config/database.yml '

cp config/config-orig.yml config/config.yml
printf >&2 'config/config.yml '

cat >config/initializers/secret_token.rb 2>/dev/null <<EOF
Quorum2::Application.config.secret_token = '`bundle exec rake secret`'
EOF
printf >&2 'config/initializers/secret_token.rb '

printf >&2 "done\n"