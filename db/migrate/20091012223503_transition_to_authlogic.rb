class TransitionToAuthlogic < ActiveRecord::Migration
  # Much of this is from http://jrmehle.com/2009/09/02/switching-from-restful_authentication-to-authlogic/ .
  def self.up
    change_column :users, :crypted_password, :string, :limit => 128, :null => false, :default => ""
    change_column :users, :salt, :string, :limit => 128, :null => false, :default => ""
    rename_column :users, :salt, :password_salt

    add_column :users, :login_count, :integer, :null => false, :default => 0
    add_column :users, :failed_login_count, :integer, :null => false, :default => 0
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
 
    add_column :users, :persistence_token, :string, :null => false, :default => ''
    add_column :users, :single_access_token, :string, :null => false, :default => ''
    add_column :users, :perishable_token, :string, :null => false, :default => ''
    add_index :users, :perishable_token

    add_column :users, :active, :boolean, :default => false, :null => false
    
    User.reset_column_information
    User.update_all("active = true", "activation_code is null")
    
    remove_column :users, :activation_code
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end

  def self.down    
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires_at, :timestamp
    
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token
    remove_column :users, :persistence_token
    
    [:login_count, :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip].each do |col|
      remove_column :users, col
    end
    
    rename_column :users, :password_salt, :salt
    change_column :users, :crypted_password, :string, :limit => 40, :null => false, :default => ""
    change_column :users, :salt, :string, :limit => 40, :null => false, :default => ""
  end
end
