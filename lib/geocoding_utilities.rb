module GeocodingUtilities
  # Sends the address contained in _string_ to a geocoder, and returns a #Point object with the resulting coordinates.
  #
  # _String_ is assumed to be in the format output by address_for_geocoding
  # (currently <tt>"#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"</tt>),
  # but depending on the geocoder, other string formats are likely to work as well.
  def coords_from_string(string)
    host = @request.nil? ? nil : @request.host_with_port
    host = host.nil? ? DOMAIN : host
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