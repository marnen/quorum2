Before do
  Geocoder.configure lookup: :test

  Geocoder::Lookup::Test.set_default_stub [
    {
      'latitude' => 1.0,
      'longitude' => 2.0
    }
  ]
end

After do
  Geocoder::Lookup::Test.reset
end