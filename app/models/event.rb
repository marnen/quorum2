class Event < ActiveRecord::Base
  belongs_to :state, :include => :country
  has_and_belongs_to_many :users
  validates_presence_of :state_id
=begin
  def coords
    c = self[:coords]
    if (c.nil?)
      address_to_code = "#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"
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
=end
end
