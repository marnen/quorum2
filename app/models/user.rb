class User < ActiveRecord::Base
  belongs_to :state
  has_many :commitments
  has_many :events, :through => :commitments
  validates_presence_of :email
  validates_length_of :md5_password, :is => 32
end
