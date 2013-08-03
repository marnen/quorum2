class ChangeGeometryColumnsToNewFormat < ActiveRecord::Migration
  def self.up
    classes.collect(&:table_name).each do |table|
      remove_column table, :coords
      add_column table, :coords, :point, geographic: true, srid: 4326
    end
    classes.each do |klass|
      klass.all.each &:save!
    end
  end

  def self.down
    classes.collect(&:table_name).each do |table|
      remove_column table, :coords
      add_column table, :coords, :point, srid: 4326
    end
  end

  private

  def self.classes
    [User, Event]
  end
end
