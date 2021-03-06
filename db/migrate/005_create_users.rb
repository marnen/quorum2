# coding: UTF-8

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => :false
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :firstname
      t.string :lastname
      t.string :street
      t.string :street2
      t.string :city
      t.integer :state_id
      t.string :zip
      t.column :coords, :point, :null => true, :with_z => false # :srid => 4326, 
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.string :activation_code, :limit => 40
      t.datetime :activated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
