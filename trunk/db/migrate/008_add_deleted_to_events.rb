class AddDeletedToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :deleted, :boolean
  end

  def self.down
    remove_column :events, :deleted
  end
end
