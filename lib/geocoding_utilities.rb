module GeocodingUtilities
  def address_for_geocoding
    "#{street}, #{city}, #{state.code}, #{zip}, #{country.code}"
  end

  def coords_from_string(string)
    geo = Geocoding::get(string, :host => "#{root_url}")
    if geo.status == Geocoding::GEO_SUCCESS
      return Point.from_coordinates(geo[0].lonlat)
    else
      raise "Geocoding failed with code #{geo.status} for #{string}"
    end
  end
end