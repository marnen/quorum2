class Event < ActiveRecord::Base
  include GeocodingUtilities
  
  belongs_to :created_by, :class_name => "User"
  belongs_to :state, :include => :country
  has_many :commitments
  has_many :users, :through => :commitments
  # validates_presence_of :city
  validates_presence_of :name
  validates_presence_of :state_id
  before_create :set_created_by_id
  
  def find_committed(status)
    # status may be :yes or :no
    # returns an array of Users with the appropriate commitment status
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
  
  def coords
    c = self[:coords]
    if c.nil?
      begin
        c = coords_from_string("#{street}, #{city}, #{state.code}, #{zip}, #{state.country.code}")
        self.update_attribute(:coords, c)
      rescue
        c = Point.from_x_y(0, 0)   
      else
      end
    end
    c
  end

 protected
  def set_created_by_id
    self.created_by = User.current_user
  end
end
