class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :site
      t.string :street
      t.string :street2
      t.string :city
      t.number :state_id
      t.string :zip
      t.number :country_id
      t.geometry :coords

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
