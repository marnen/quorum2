namespace :db do
  desc 'Install PostGIS in the database'
  task install_postgis: :environment do
    ActiveRecord::Base.connection.execute 'CREATE EXTENSION postgis;'
  end

  desc 'Create database and load PostGIS and schema'
  task setup_with_postgis: %w(db:create db:install_postgis db:schema:load)
end