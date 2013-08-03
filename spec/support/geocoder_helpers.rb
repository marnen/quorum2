module GeocoderHelpers
  def geocoder_stub(stubs, &block)
    begin
      geocoder = Geocoder::Lookup::Test
      old_stubs = geocoder.stubs.dup

      stubs.each do |address, results|
        geocoder.add_stub address, results
      end
      yield
    ensure
      stubs.each do |address, _|
        geocoder.stubs.delete address
      end
      old_stubs.each do |address, results|
        geocoder.add_stub address, results
      end
    end
  end
end