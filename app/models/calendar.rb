class Calendar < ActiveRecord::Base
  has_many :events
  has_many :permissions
  has_many :users, :through => :permissions
  
  validates_presence_of :name
  
  after_create :set_admin
  
  def to_s
    self.name
  end
  
  
 protected
  def set_admin
    self.permissions.create(:user => User.current_user, :role => Role.find_by_name('admin'))
  end
end
