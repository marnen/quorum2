class Event < ActiveRecord::Base
  belongs_to :created_by, :class_name => "User"
  belongs_to :state, :include => :country
  has_many :commitments
  has_many :users, :through => :commitments
  validates_presence_of :city
  validates_presence_of :created_by_id
  validates_presence_of :state_id
  before_create do
    self.created_by = AuthenticatedSystem::current_user
  end
  
  def find_committed(status)
    # status may be :yes or :no
    # returns an array of Users with the appropriate commitment status
    temp = commitments.clone
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
  
  # This is duplicated in User. Perhaps we can refactor.

  def coords
    c = self[:coords]
    if (c.nil?)
      address_to_code = "#{street}, #{city}, #{state.code}, #{zip}, #{state.country.code}"
      begin
        geo = Geocoding::get(address_to_code)
        if geo.status == Geocoding::GEO_SUCCESS
          c = write_attribute(:coords, Point.from_coordinates(geo[0].lonlat))
          self.save!
        else
          raise "Geocoding failed with code #{geo.status} for #{address_to_code}"
        end
      rescue
        write_attribute(:coords, nil)
        c = Point.from_x_y(0, 0)
      end
    end
   c
  end
end
