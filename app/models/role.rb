class Role < ActiveRecord::Base
  has_many :users
  validates_presence_of :name
  
  def to_s
    _(self.name)
  end
end
