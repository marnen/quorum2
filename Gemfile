source 'http://rubygems.org'

gem 'rails', '~> 3.1.4'

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
gem 'sass'
gem 'pg'
gem 'gettext_i18n_rails'
gem 'prawn'
gem 'activerecord-postgis-adapter'
gem 'GeoRuby', require: 'geo_ruby'
gem 'rdiscount'
gem 'authlogic'
gem 'dynamic_form'
gem 'exception_notification'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :development do
  gem 'capistrano'
  gem 'gettext', '>= 1.9.3', :require => false
end

group :test, :development do
  gem 'ruby-debug19'
  gem 'autotest-rails', :require => false
  gem 'rspec-rails', '~> 2.6.1', :require => false
  gem 'test-unit', '1.2.3', :require => false # amazingly, RSpec needs this
  gem 'cucumber-rails', :require => false
  gem 'launchy'
  gem 'pickle'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'ffaker'
end

