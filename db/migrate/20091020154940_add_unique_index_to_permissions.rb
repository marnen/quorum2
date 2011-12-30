# coding: UTF-8

class AddUniqueIndexToPermissions < ActiveRecord::Migration
  def self.up
    add_index :permissions, [:user_id, :calendar_id, :role_id], :unique => true
  end

  def self.down
    remove_index :permissions, [:user_id, :calendar_id, :role_id]
  end
end
