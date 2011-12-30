# coding: UTF-8

class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :calendar
  belongs_to :role
  
  validates_presence_of :user_id
  validates_presence_of :calendar_id
  validates_presence_of :role_id
  validates_uniqueness_of :calendar_id, :scope => [:role_id, :user_id]
end
