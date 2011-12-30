# coding: UTF-8

class AddFeedKeyToUsers < ActiveRecord::Migration
  def self.up
    # This is a unique key for each user's RSS feeds
    execute "ALTER TABLE users ADD COLUMN feed_key char(32) NOT NULL DEFAULT md5(random() || '')" # can't do computed defaults in Rails migrations yet :(
    add_index :users, :feed_key, :unique => true
  end

  def self.down
    remove_index :users, :feed_key
    remove_column :users, :feed_key
  end
end
