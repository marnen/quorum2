class Event < ActiveRecord::Base
  include GeocodingUtilities
  
  belongs_to :created_by, :class_name => "User"
  belongs_to :state, :include => :country
  belongs_to :calendar
  has_many :commitments
  has_many :users, :through => :commitments
  # validates_presence_of :city
  validates_presence_of :calendar_id
  validates_presence_of :name
  validates_presence_of :state_id
  before_create :set_created_by_id
  before_update :clear_coords
  
  # Returns true if #User.current_user is allowed to perform <i>operation</i> on the current #Event, false otherwise.
  # <i>Operation</i> may be <tt>:edit</tt>, <tt>:delete</tt>, or <tt>:show</tt>.
  def allow?(operation)
    u = User.current_user
    if !u.kind_of? User
      return nil
    else
      p = u.permissions.find_by_calendar_id(self.calendar_id)
      if p.nil?
        return false
      end
      role = p.role
      if role.nil?
        return false
      else
        case operation
          when :delete
            return role.name == 'admin'
          when :edit
            if self.created_by == u or role.name == 'admin'
              return true
            else
              return false
            end
          when :show
            return true # yes, this actually works, since we take care of the case where the user has no permissions above
          else
            return nil
        end
      end
    end
  end
  
  # Returns an #Array of #User objects with commitment status (for the current #Event) of <i>status</i>,
  # where <i>status</i> may be <tt>:yes</tt> or <tt>:no</tt>.
  def find_committed(status)
    temp = self.commitments.clone
    if status == :yes then
      temp.delete_if {|e| e.status != true}
      temp.collect{|e| e.user }
    elsif status == :no then
      temp.delete_if {|e| e.status != false}
      temp.collect{|e| e.user }
    else
      raise "Invalid status: " << status
    end
  end
  
  # Hides the current #Event. This has the effect of deleting it, since hidden Events will not show up in the main list.
  def hide
    self.deleted = true
    self.save
  end
  
  # Nil-safe country accessor.
  def country
    if self.state.nil?  
      nil
    else
      self.state.country
    end
  end
  
  # Returns a #Point with the coordinates of the #Event's address, or with (0, 0) if all else fails, and caches the coordinates so we don't hit the geocoder every time.
  def coords
    c = self[:coords]
    if c.nil?
      begin
        c = coords_from_string(address_for_geocoding)
        self[:coords] = c
        self.save
      rescue
        c = Point.from_x_y(0, 0)   
      end
    end
    c
  end

 protected
  def clear_coords
    self.coords = nil
  end
 
  def set_created_by_id
    self.created_by = User.current_user
  end
end
