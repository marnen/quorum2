module GeocodingUtilities
  def address_for_geocoding
    "#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"
  end

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