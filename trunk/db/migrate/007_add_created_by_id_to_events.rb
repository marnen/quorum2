class AddCreatedByIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :created_by_id, :integer
  end

  def self.down
    remove_column :events, :created_by_id
  end
end
