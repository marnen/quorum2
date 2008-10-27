class Calendar < ActiveRecord::Base
  has_many :events
  has_many :permissions
  has_many :users, :through => :permissions
  
  def to_s
    self.name
  end
end
