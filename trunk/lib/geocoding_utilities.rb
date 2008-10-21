module GeocodingUtilities
  # Returns the current object's address in a form suitable for feeding to a geocoder (perhaps through coords_from_string).
  def address_for_geocoding
    "#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"
  end

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
end