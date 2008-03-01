class User < ActiveRecord::Base
  belongs_to :state
  has_many :commitments
  has_many :events, :through => :commitments
  validates_presence_of :email
  validates_length_of :md5_password, :is => 32
  
  def fullname
    str = [self.firstname, self.lastname].delete_if {|e| e.blank?}.join(' ')
    str.blank? ? self.email : str
  end
end
