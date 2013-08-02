module GeocoderHelpers
  def geocoder_stub(stubs, &block)
    begin
      geocoder = Geocoder::Lookup::Test
      old_stubs = {}

      stubs.each do |address, results|
        old_stubs[address] = geocoder.stubs[address]
        geocoder.add_stub address, results
      end
      yield
    ensure
      old_stubs.each do |address, results|
        geocoder.stubs[address] = results
      end
    end
  end
end