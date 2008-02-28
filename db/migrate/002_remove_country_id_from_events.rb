class RemoveCountryIdFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :country_id
  end

  def self.down
    add_column :events, :country_id, :integer
  end
end
