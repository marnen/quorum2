# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "commitments", :force => true do |t|
    t.column "event_id", :integer, :null => false
    t.column "status", :boolean
    t.column "user_id", :integer
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
    t.column "coords", :point
    t.column "created_by_id", :integer
    t.column "deleted", :boolean
  end

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
    t.column "crypted_password", :string, :limit => 40
    t.column "salt", :string, :limit => 40
    t.column "firstname", :string
    t.column "lastname", :string
    t.column "street", :string
    t.column "street2", :string
    t.column "city", :string
    t.column "state_id", :integer
    t.column "zip", :string
    t.column "remember_token", :string
    t.column "remember_token_expires_at", :timestamp
    t.column "activation_code", :string, :limit => 40
    t.column "activated_at", :timestamp
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "coords", :point
    t.column "role_id", :integer, :default => 1
  end

end
