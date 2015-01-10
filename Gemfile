source 'http://rubygems.org'

ruby '2.0.0'

gem 'rails', '~> 4.0.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem 'haml'
gem 'prototype-rails' # TODO: remove when we switch to jQuery.
gem 'pg'
gem 'gettext_i18n_rails'
gem 'iconv'
gem 'prawn'
gem 'prawn-rails', github: 'cortiz/prawn-rails', ref: '261ed59ca55420a590811c31eadd9606d4c067ae' # TODO: waiting for https://github.com/cortiz/prawn-rails/issues/6
gem 'geocoder', '~> 1.1.8'
gem 'rdiscount'
gem 'activerecord-postgis-adapter'
gem 'acts_as_addressed', path: './acts_as_addressed'
gem 'authlogic', github: 'marnen/authlogic', branch: 'backport-pull-369-onto-v3.3.0' # TODO: waiting for https://github.com/binarylogic/authlogic/pull/446
gem 'dynamic_form'
gem 'exception_notification'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier',     '>= 1.0.3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :development do
  gem 'rvm-capistrano'
  gem 'gettext', '>= 1.9.3', :require => false
end

group :test, :development do
  gem 'autotest-rails', :require => false
  gem 'rspec-rails', '~> 2.13.1', :require => false
  gem 'test-unit', '1.2.3', :require => false # amazingly, RSpec needs this
  gem 'byebug'
  gem 'cucumber-rails', :require => false
  gem 'capybara', '>= 1.0.1', '< 2' # TODO: temporary only, to get Cucumber working. We should remove this line and rewrite for Capybara 2.
  gem 'launchy'
  gem 'pickle', github: 'ianwhite/pickle', ref: 'd2e4bb87f9ea218b763c9375b29fe75363c4b3c4' # TODO: waiting for https://github.com/ianwhite/pickle/pull/48
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'ffaker'
end

