class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    Role.create :name => "user"
    Role.create :name => "admin"

    user = Role.find_by_name("user").id
    add_column :users, :role_id, :integer, :default => user
    User.reset_column_information
    User.find(:all).each do |u|
      if u.role_id.nil?
        u.role_id = user
      end
    end
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
  end
end
