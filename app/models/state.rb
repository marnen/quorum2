class State < ActiveRecord::Base
  belongs_to :country
  validates_presence_of :country_id
  validates_presence_of :code
  validates_presence_of :name
end
