# coding: UTF-8

class AddShowContactToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :show_contact, :boolean, :default => true
    User.reset_column_information
    User.find(:all).each do |u|
      if u.show_contact.nil?
        u.update_attribute(:show_contact, false) # so that existing users have to actively turn the flag on
      end
    end
  end

  def self.down
    remove_column :users, :show_contact
  end
end
