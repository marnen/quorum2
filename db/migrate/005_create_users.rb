class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => :false
      t.string :md5_password, :null => :false, :limit => 32
      t.string :salt, :limit => 5
      t.string :firstname
      t.string :lastname
      t.string :address
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zip
      t.geometry :coords, :point, :null => true, :srid => 4326, :with_z => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
