class CreateCalendars < ActiveRecord::Migration
  def self.up
    create_table :calendars do |t|
      t.string :name, :null => false
      t.timestamps
    end

    @cal = Calendar.new(:name => 'Default calendar')
    @cal.save!

    add_column :events, :calendar_id, :integer, :deferrable => true
    Event.reset_column_information
    Event.find(:all).each do |e|
      e.update_attribute :calendar_id, @cal.id
    end
    change_column :events, :calendar_id, :integer, :null => false

    create_table :permissions do |t|
      t.integer :user_id, :deferrable => true, :null => false
      t.integer :calendar_id, :deferrable => true, :null => false
      t.integer :role_id, :deferrable => true, :null => false
    end

    Permission.reset_column_information
    User.find(:all).each do |u|
      Permission.create!(:user_id => u.id, :role_id => u.role_id, :calendar_id => @cal.id)
    end
    
    remove_column :users, :role_id
  end

  def self.down
    add_column :users, :role_id, :integer, :deferrable => true
    User.reset_column_information
    Permission.find(:all).each do |p|
      u = User.find(p.user_id)
      u.update_attribute :role_id, p.role_id
    end
    change_column :users, :role_id, :integer, :null => false
    
    drop_table :permissions
    remove_column :events, :calendar_id
    drop_table :calendars
  end
end
