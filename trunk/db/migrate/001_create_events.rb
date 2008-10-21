class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :site
      t.string :street
      t.string :street2
      t.string :city
      t.integer :state_id
      t.string :zip
      t.integer :country_id
      t.column :coords, :point, :null => true, :with_z => false # :srid => 4326, 

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
