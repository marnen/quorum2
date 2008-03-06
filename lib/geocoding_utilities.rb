module GeocodingUtilities
  def coords_from_string(string)
    geo = Geocoding::get(string)
    if geo.status == Geocoding::GEO_SUCCESS
      return Point.from_coordinates(geo[0].lonlat)
    else
      raise "Geocoding failed with code #{geo.status} for #{string}"
    end
  end
end