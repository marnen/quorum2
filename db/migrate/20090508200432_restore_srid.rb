# coding: UTF-8

class RestoreSrid < ActiveRecord::Migration
  def self.up
    srid = GeoRuby::SimpleFeatures::DEFAULT_SRID.to_i
    ['events', 'users'].each do |table|
      change_srid(table, srid)
    end
  end

  def self.down
    srid = -1
    ['events', 'users'].each do |table|
      change_srid(table, srid)
    end
  end

  private
 
  def self.change_srid(table, srid = -1)
    execute "select updategeometrysrid('#{table}', 'coords', #{srid})"
    execute "select setsrid(coords, #{srid}) from #{table}"
  end
end
