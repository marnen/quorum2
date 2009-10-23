module Acts::Addressed
  class Country < ActiveRecord::Base
    has_many :states
    validates_length_of :code, :is => 2
    validates_presence_of :name
  end
end