class CreateStatesAndCountries < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.integer :country_id
      t.string :code, :limit => 10, :null => false
      t.string :name, :null => false
    end
    
    create_table :countries do |t|
      t.string :code, :limit => 2, :null => false
      t.string :name, :null => false
    end
  end

  def self.down
    drop_table :states
    drop_table :countries
  end
end
