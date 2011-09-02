source 'http://rubygems.org'

gem 'rails', '3.0.10'

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
gem 'fast_gettext'
gem 'prawn'
gem 'GeoRuby'
gem 'rdiscount', '>= 1.2.11'
gem 'authlogic', '~> 3.0.3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :development do
  gem 'gettext', '>= 1.9.3', :require => false
end

group :test, :development do
  gem 'ruby-debug'
  gem 'autotest', :require => false
  gem 'autotest-rails', :require => false
  gem 'rspec-rails', '~> 2.6.1', :require => false
  gem 'cucumber-rails', :require => false
  gem 'machinist', '>= 1.0.3'
  gem 'ffaker'
end

