class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :calendar
  belongs_to :role
  
  validates_presence_of :user_id
  validates_presence_of :calendar_id
  validates_presence_of :role_id
end
