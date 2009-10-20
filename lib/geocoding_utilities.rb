module GeocodingUtilities
  def self.included(klass)
    klass.before_update :clear_coords
  end
  
  # Returns a #Point with the coordinates of the model's address, or with (0, 0) if all else fails, and caches the coordinates so we don't hit the geocoder every time.
  def coords
    c = self[:coords]
    if c.nil?
      begin
        c = coords_from_string(address.to_s(:geo))
        self[:coords] = c
        self.save
      rescue
        c = Point.from_x_y(0, 0)   
      end
    end
    c
  end

  # Sends the address contained in _string_ to a geocoder, and returns a #Point object with the resulting coordinates.
  #
  # _String_ is assumed to be in the format output by #Address#to_s(:geo)
  # (currently <tt>"#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"</tt>),
  # but depending on the geocoder, other string formats are likely to work as well.
  def coords_from_string(string)
    host = @request.nil? ? nil : @request.host_with_port
    host ||= DOMAIN
    geo = Geocoding::get(string, :host => host)
    if geo.status == Geocoding::GEO_SUCCESS
      return Point.from_coordinates(geo[0].lonlat)
    else
      raise "Geocoding failed with code #{geo.status} for #{string}"
    end
  end
  
  # Clears the coordinates of the model so they will refresh themselves next time Model.coords is called
  def clear_coords
    self.coords = nil
  end
end