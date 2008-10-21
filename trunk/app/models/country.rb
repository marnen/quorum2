class Country < ActiveRecord::Base
  validates_length_of :code, :is => 2
  validates_presence_of :name
end
