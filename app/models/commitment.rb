# coding: UTF-8

class Commitment < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  validates_presence_of :event_id
  validates_presence_of :user_id
  
  scope :attending, :conditions => {:status => true}
  scope :not_attending, :conditions => {:status => false}
end
