Geocoder.configure lookup: :test

Geocoder::Lookup::Test.set_default_stub [
  {
    'latitude' => 1.0,
    'longitude' => 2.0
  }
]