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
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commitments", :force => true do |t|
    t.integer "event_id", :null => false
    t.integer "user_id",  :null => false
    t.boolean "status"
    t.text    "comment"
  end

  create_table "countries", :force => true do |t|
    t.string "code", :limit => 2, :null => false
    t.string "name",              :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.string   "site"
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.boolean  "deleted"
    t.text     "description"
    t.integer  "calendar_id",                                            :null => false
    t.spatial  "coords",        :limit => {:srid=>4326, :type=>"point"}
  end

  create_table "permissions", :force => true do |t|
    t.integer "user_id",                          :null => false
    t.integer "calendar_id",                      :null => false
    t.integer "role_id",                          :null => false
    t.boolean "show_in_report", :default => true, :null => false
  end

  add_index "permissions", ["user_id", "calendar_id", "role_id"], :name => "index_permissions_on_user_id_and_calendar_id_and_role_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.integer "country_id"
    t.string  "code",       :limit => 10, :null => false
    t.string  "name",                     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password",    :limit => 128,                           :default => "",    :null => false
    t.string   "password_salt",       :limit => 128,                           :default => "",    :null => false
    t.string   "firstname"
    t.string   "lastname"
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_contact",                                                 :default => true
    t.string   "single_access_token", :limit => 32,                                               :null => false
    t.integer  "login_count",                                                  :default => 0,     :null => false
    t.integer  "failed_login_count",                                           :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "persistence_token",                                            :default => "",    :null => false
    t.string   "perishable_token",                                             :default => "",    :null => false
    t.boolean  "active",                                                       :default => false, :null => false
    t.spatial  "coords",              :limit => {:srid=>4326, :type=>"point"}
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["single_access_token"], :name => "index_users_on_single_access_token"

end
