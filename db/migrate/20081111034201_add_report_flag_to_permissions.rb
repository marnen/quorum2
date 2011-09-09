# coding: UTF-8

class AddReportFlagToPermissions < ActiveRecord::Migration
  def self.up
    add_column :permissions, :show_in_report, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :permissions, :show_in_report
  end
end
