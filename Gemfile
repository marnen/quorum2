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
gem 'prawn-rails'
gem 'geocoder', '~> 1.1.8'
gem 'rdiscount'
gem 'rgeo-activerecord', github: 'marnen/rgeo-activerecord', branch: 'fix-proc-error-in-default-factory' # TODO: waiting for https://github.com/dazuma/rgeo-activerecord/pull/10
gem 'activerecord-postgis-adapter'
gem 'acts_as_addressed', path: './acts_as_addressed'
gem 'authlogic', '~> 3.4.4'
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
  # gem 'term-ansicolor' # TODO: Cucumber loads it but doesn't declare the dependency; remove if future versions declare the dependency.
  gem 'capybara', '>= 1.0.1', '< 2' # TODO: temporary only, to get Cucumber working. We should remove this line and rewrite for Capybara 2.
  gem 'launchy'
  gem 'pickle'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'ffaker'
end

