class Commitment < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  validates_presence_of :event_id
  validates_presence_of :user_id
  
  named_scope :attending, :conditions => {:status => true}
  named_scope :not_attending, :conditions => {:status => false}
end
