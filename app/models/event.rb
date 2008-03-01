class Event < ActiveRecord::Base
  belongs_to :state, :include => :country
  has_many :commitments
  has_many :users, :through => :commitments
  validates_presence_of :city
  validates_presence_of :state_id
  
  def find_committed(status = :yes)
    # status may be :yes, :no, or nil
    # returns an array of Users with the appropriate commitment status
    if status.nil? then
      nil
    elsif status == :yes then
      nil
    elsif status == :no then
      nil
    else
      raise "Invalid status: " << status
    end
  end

  def coords
    c = self[:coords]
    if (c.nil?)
      address_to_code = "#{street}, #{city}, #{state.code}, #{zip}, #{state.country.code}"
      begin
        geo = Geocoding::get(address_to_code)
        if geo.status == Geocoding::GEO_SUCCESS
          c = write_attribute(:coords, Point.from_coordinates(geo[0].lonlat))
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
