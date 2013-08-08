Given /^the address "([^"]*)" has latitude: (-?[\d.]+), longitude, (-?[\d.]+)$/ do |address, latitude, longitude|
  Geocoder::Lookup::Test.add_stub address, [
    {
      'latitude' => latitude.to_f,
      'longitude' => longitude.to_f
    }
  ]
end