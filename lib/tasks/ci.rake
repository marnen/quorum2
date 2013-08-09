namespace :db do
  desc 'Install PostGIS in the database'
  task install_postgis: :environment do
    ActiveRecord::Base.connection.execute 'CREATE EXTENSION postgis;'
  end

  desc 'Create database and load PostGIS and schema'
  task setup_with_postgis: %w(db:create db:install_postgis db:schema:load)
end

desc 'Run CI tests (intended for Travis)'
task ci: %w(db:setup_with_postgis ci:rspec ci:cucumber)

namespace :ci do
  task :rspec do
    sh 'bundle exec rspec -O .rspec.travis'
  end

  task cucumber: %w(ci:cucumber:no_javascript ci:cucumber:javascript)

  namespace :cucumber do
    task :no_javascript 'db:setup_with_postgis' do
      sh 'bundle exec cucumber --tags ~@javascript'
    end

    task :javascript 'db:setup_with_postgis' do
      sh 'xvfb-run bundle exec cucumber --tags @javascript'
    end
  end
end