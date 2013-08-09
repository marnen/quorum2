#!/usr/bin/env sh
warn () {
  printf >&2 "$*"
}

warn 'Setting up config files... '
cat >config/database.yml <<EOF
test:
  adapter: postgis
  database: quorum2_test
  username: postgres
  encoding: UTF8
EOF
warn 'config/database.yml '

cp config/config-orig.yml config/config.yml
warn 'config/config.yml '

cat >config/initializers/secret_token.rb 2>/dev/null <<EOF
Quorum2::Application.config.secret_token = '`bundle exec rake secret`'
EOF
warn 'config/initializers/secret_token.rb '

warn "done\n"