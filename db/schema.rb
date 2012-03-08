# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120308160523) do

  create_table "calendars", :force => true do |t|
    t.column "name", :string, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "commitments", :force => true do |t|
    t.column "event_id", :integer, :null => false
    t.column "user_id", :integer, :null => false
    t.column "status", :boolean
    t.column "comment", :text
  end

  create_table "countries", :force => true do |t|
    t.column "code", :string, :limit => 2, :null => false
    t.column "name", :string, :null => false
  end

  create_table "events", :force => true do |t|
    t.column "name", :string
    t.column "date", :date
    t.column "site", :string
    t.column "street", :string
    t.column "street2", :string
    t.column "city", :string
    t.column "state_id", :integer
    t.column "zip", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "created_by_id", :integer
    t.column "deleted", :boolean
    t.column "description", :text
    t.column "calendar_id", :integer, :null => false
    t.column "coords", :point, :srid => 4326
  end

  create_table "permissions", :force => true do |t|
    t.column "user_id", :integer, :null => false
    t.column "calendar_id", :integer, :null => false
    t.column "role_id", :integer, :null => false
    t.column "show_in_report", :boolean, :default => true, :null => false
  end

  add_index "permissions", ["user_id", "calendar_id", "role_id"], :name => "index_permissions_on_user_id_and_calendar_id_and_role_id", :unique => true

  create_table "roles", :force => true do |t|
    t.column "name", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "states", :force => true do |t|
    t.column "country_id", :integer
    t.column "code", :string, :limit => 10, :null => false
    t.column "name", :string, :null => false
  end

  create_table "users", :force => true do |t|
    t.column "email", :string
    t.column "crypted_password", :string, :limit => 128, :default => "", :null => false
    t.column "password_salt", :string, :limit => 128, :default => "", :null => false
    t.column "firstname", :string
    t.column "lastname", :string
    t.column "street", :string
    t.column "street2", :string
    t.column "city", :string
    t.column "state_id", :integer
    t.column "zip", :string
    t.column "activated_at", :timestamp
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "show_contact", :boolean, :default => true
    t.column "single_access_token", :string, :limit => 32, :null => false
    t.column "login_count", :integer, :default => 0, :null => false
    t.column "failed_login_count", :integer, :default => 0, :null => false
    t.column "last_request_at", :timestamp
    t.column "current_login_at", :timestamp
    t.column "last_login_at", :timestamp
    t.column "current_login_ip", :string
    t.column "last_login_ip", :string
    t.column "persistence_token", :string, :default => "", :null => false
    t.column "perishable_token", :string, :default => "", :null => false
    t.column "active", :boolean, :default => false, :null => false
    t.column "coords", :point, :srid => 4326
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["single_access_token"], :name => "index_users_on_single_access_token"

end
