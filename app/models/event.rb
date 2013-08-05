# coding: UTF-8
require 'acts/geocoded'

class Event < ActiveRecord::Base
  acts_as_geocoded

  belongs_to :created_by, :class_name => "User"
  belongs_to :calendar
  has_many :commitments
  has_many :users, :through => :commitments
  # validates_presence_of :city
  validates_presence_of :calendar_id
  validates_presence_of :name
  validates_presence_of :state_id

  before_create :set_created_by_id

  default_scope :conditions => 'deleted is distinct from true'

  # Returns true if #User.current_user is allowed to perform <i>operation</i> on the current #Event, false otherwise.
  # <i>Operation</i> may be <tt>:edit</tt>, <tt>:delete</tt>, or <tt>:show</tt>.
  def allow?(operation)
    u = User.current_user
    if !u.kind_of? User
      return nil
    else
      begin
        send(['allow_', operation, '?'].join.to_sym, u)
      rescue NoMethodError
        return nil
      end
    end
  end

  # Sets the #User's attendance status on the Event, where status is one of true (attending), false (not attending), or nil (uncommitted).
  def change_status!(user, status, comment = nil)
    commitment = commitments.find_or_create_by_user_id(user.id)
    commitment.update_attributes! :status => status, :comment => comment
  end

  # Returns an array of nonblank comments for the #Event, ordered by #User's name.
  def comments
    commitments.reject {|c| c.comment.blank? }.sort_by &:user
  end

  # Returns an #Array of #User objects with commitment status (for the current #Event) of <i>status</i>,
  # where <i>status</i> may be <tt>:yes</tt> or <tt>:no</tt>.
  def find_committed(status)
    if ![:yes, :no].include? status
      raise "Invalid status (not :yes or :no): " << status
    end
    status_to_find = {yes: true, no: false}[status]
    found_commitments = commitments.select {|c| c.status == status_to_find }
    found_commitments.collect {|e| e.user }.sort
  end

  # Hides the current #Event. This has the effect of deleting it, since hidden Events will not show up in the main list.
  def hide
    self.deleted = true
    self.save
  end

  def latitude
    coords.try :y
  end

  def longitude
    coords.try :x
  end

  protected
  # TODO: allow_* methods should probably be public. Keeping them protected mainly so as not to change the class interface just yet.
  def allow_delete?(user)
    role = role_of user
    !role.nil? and role.name == 'admin'
  end

  def allow_edit?(user)
    if created_by == user
      return true
    else
      role = role_of user
      return role.name == 'admin'
    end
  end

  def allow_show?(user)
    !(role_of user).nil?
  end

  # TODO: should this method be public?
  # Returns the #Role of the #User for the #Event.
  def role_of(user)
    # TODO: use joins to make one DB query, not two.
    p = user.permissions.find_by_calendar_id(self.calendar_id)
    p.nil? ? nil : p.role
  end

  def set_created_by_id
    if User.current_user and User.current_user != :false
      self.created_by = User.current_user
    end
  end
end
